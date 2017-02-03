//
//  ShiftsModel.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import EventKit
import UIKit


struct Shift {
    let date:Date
    let value:String
    
    var description: String {
        get {
            let df = DateFormatter()
            df.dateFormat = "YYYY-mm-dd"
            return df.string(from: date) + ":" + value
        }
    }
    
    var abbreviation: String {
        get {
            return value.substring(to: value.index(value.startIndex, offsetBy: 1))
        }
    }
    
    init(date:Date, value:String) {
        self.date = date
        self.value = value
    }
}

class ShiftStorage {
    var shifts:[Shift] = [] {
        didSet {
            callback?()
        }
    }
    var callback: (() -> ())?
    
    var description: String {
        get {
            return "[" + shifts.map { shift in return shift.description }.joined(separator:",") + "]"
        }
        
    }
    
    var summary: String {
        get {
            return shifts.map { shift in return shift.abbreviation }.joined(separator: " ")
        }
    }
    
    func add(_ date: Date, value:String) {
        let newShift = Shift(date:date, value:value)
        if let pos = self.indexOfRow(forDate: date) {
            shifts[pos] = newShift
            return
        }

        
        if let pos = shifts.index(where: { shift in shift.date >= date }) {
            shifts.insert(newShift, at: pos)
        } else {
            shifts.append(newShift)
        }
    }
    
    func remove(_ date:Date) {
        if let index = shifts.index(where:{ shift in shift.date == date }) {
            shifts.remove(at: index)
        }
    }
    
    // Sets the callback to be called when the data in the shiftStorage changes
    func notifyChanges(to: @escaping () -> ()) {
        callback = to
    }
    
    // Returns the index of the shift with the given date.
    // This methods returns nil if such shift does not exist
    func indexOfRow(forDate date:Date) -> Int? {
        let calendar = Calendar(identifier: .gregorian)
        return shifts.index(where: { shift in return calendar.isDate(shift.date, inSameDayAs: date) })
    }
}

enum CalendarUpdaterError {
    case accessNotGranted
    case accessError(String)
    case updateError(String)
}


class CalendarShiftUpdater {
    var store = EKEventStore()
    var targetCalendar: EKCalendar? {
        didSet {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.options.calendar = targetCalendar!.title
        }
    }
    
    var calendars: [EKCalendar] {
        get {
            // FIXME: This should return a list of calendars filtered
            //   so to filter out non editable calendars
            return store.calendars(for: .event)
        }
    }
    
    static func isAccessGranted() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    func requestAccess() {
        store.requestAccess(to: .event, completion:{ granted, error in
            if !granted || error != nil {
                if !granted {
                    NSLog("Not granted")
                } else {
                    NSLog("Error")
                }
            }
            
        })
    }


    func update(with shiftStorage:ShiftStorage) throws {
        for shift in shiftStorage.shifts {
            if targetCalendar == nil {
                targetCalendar = store.defaultCalendarForNewEvents
            }
            
            do {
                let event = EKEvent(eventStore: store)
                
                event.startDate = shift.date
                event.endDate = shift.date
                event.isAllDay = true
                event.title = shift.value
                event.calendar = targetCalendar!
                
                try store.save(event, span: EKSpan.thisEvent)
                NSLog("event saved: " + shift.description)
            } catch {
                NSLog("error occurred: " + shift.description)
            }
        }
    }
}
