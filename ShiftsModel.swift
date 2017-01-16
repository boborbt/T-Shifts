//
//  ShiftsModel.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import EventKit

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
        if !shifts.contains { shift in shift.date == date } {
            shifts.append(Shift(date:date, value:value))
        }
    }
    
    func remove(_ date:Date) {
        if let index = shifts.index(where:{ shift in shift.date == date }) {
            shifts.remove(at: index)
        }
    }
    
    func notifyChanges(to: @escaping () -> ()) {
        callback = to
    }
}

class CalendarShiftUpdater {
    func update(with shiftStorage:ShiftStorage) {
        let store = EKEventStore()
        
        store.requestAccess(to: .event, completion:{ granted, error in
            if !granted || error != nil {
                NSLog("access not granted or error occurred")
                return
            }

            for shift in shiftStorage.shifts {
                do {
                    
                    let event = EKEvent(eventStore: store)

                    event.startDate = shift.date
                    event.endDate = shift.date
                    event.isAllDay = true
                    event.title = shift.value
                    event.calendar = store.defaultCalendarForNewEvents

                    try store.save(event, span: EKSpan.thisEvent)
                    NSLog("event saved: " + shift.description)
                } catch {
                    NSLog("error occurred: " + shift.description)
                }
            }
        })
    }
}
