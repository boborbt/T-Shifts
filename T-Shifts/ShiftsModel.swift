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

protocol ShiftStorage: Sequence {
    func add(shift: Shift, toDate: Date) throws
    func remove(shift:Shift, fromDate: Date) throws
    func isPresent(shift: Shift, at date: Date) -> Bool
    
    func shifts(at date: Date) -> [Shift]
    
    func notifyChanges(to function:@escaping (Date)->() )
}


struct Shift: Equatable, Hashable {
    public var hashValue: Int {
        get {
            return shortcut.hashValue
        }
    }

    var description: String
    var shortcut: String
    
    static func == (lhs: Shift, rhs: Shift) -> Bool {
        return lhs.shortcut == rhs.shortcut
    }
}

struct ShiftTemplate {
    var shift: Shift
    var position: Int
    var color: UIColor
}

class ShiftTemplates {
    var templates: [ShiftTemplate] = []
    
    func add(shift: Shift, position: Int, color: UIColor) {
        templates.append( ShiftTemplate(shift: shift, position: position, color: color))
    }
    
    func template(for shift: Shift) -> ShiftTemplate? {
        return templates.first(where: { template in template.shift.shortcut == shift.shortcut })
    }
    
    func template(at position: Int) -> ShiftTemplate? {
        return templates.first(where: { template in template.position == position })
    }
    
    func template(havingDescription description:String) -> ShiftTemplate? {
        return templates.first(where: { template in template.shift.description == description} )
    }
}

class CalendarShiftStorage : ShiftStorage {
    var callback: ((Date) -> ())!
    weak var shiftTemplates: ShiftTemplates!
    weak var calendarUpdater: CalendarShiftUpdater!
    
    init(updater: CalendarShiftUpdater, templates: ShiftTemplates) {
        calendarUpdater = updater
        shiftTemplates = templates
    }
    
    func add(shift: Shift, toDate date: Date) throws {
        try calendarUpdater.add(shift: shift, at: date)
        callback(date)
    }
    
    func remove(shift:Shift, fromDate date: Date) throws {
        try calendarUpdater.remove(shift: shift, at: date)
        callback(date)
    }
    
    func isPresent(shift: Shift, at date: Date) -> Bool  {
        let shifts = self.shifts(at: date)
        return shifts.index(where: { s in shift == s }) != nil
    }
    
    func shifts(at date: Date) -> [Shift] {
        let store = calendarUpdater.store
        let predicate = store.predicateForEvents(withStart: date, end: date + 1.days(), calendars: [calendarUpdater.targetCalendar!])
        let events = calendarUpdater.store.events(matching: predicate)
        
        return events.flatMap({ (event) in
            let description = event.title
            return self.shiftTemplates.shift(havingDescription: description)
        })
    }
    
    func makeIterator() -> DictionaryIterator<Date,[Shift]> {
        return [:].makeIterator()
    }
    
    func notifyChanges(to function: @escaping (Date) -> ()) {
        callback = function
    }

}

class LocalShiftStorage: ShiftStorage {
    var storage: [Date:[Shift]] = [:]
    var callback: ((Date) -> ())!
    
    func isPresent(shift: Shift, at date: Date) -> Bool {
        let shifts = self.shifts(at: date)
        return shifts.index(where: { s in shift == s }) != nil
    }

    
    func add(shift: Shift, toDate date: Date) throws {
        if storage[date] == nil {
            storage[date] = []
        }
        
        if let _ = storage[date]!.index(of:shift) {
            return
        }
        
        storage[date]!.append(shift)
        
        callback!(date)
    }
    
    func remove(shift:Shift, fromDate date: Date) {
        var dateInfo = storage[date]
        
        if let index = dateInfo?.index(of: shift) {
            dateInfo?.remove(at: index)
        }
        
        callback(date)
    }
        
    func shifts(at date: Date) -> [Shift] {
        guard let result = storage[date] else { return [] }
        return result
    }
    
    func makeIterator() -> DictionaryIterator<Date,[Shift]> {
        return storage.makeIterator()
    }
    
    func notifyChanges(to function: @escaping (Date) -> ()) {
        callback = function
    }
}


class CalendarShiftUpdater {
    var store = EKEventStore()
    var targetCalendar: EKCalendar? {
        didSet {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            delegate.options.calendar = targetCalendar!.title
        }
    }
    
    init(calendarName:String) {
        let calendar = store.calendars(for: .event).first(where: { calendar in calendar.title == calendarName})
        
        if calendar != nil {
            targetCalendar = calendar
        } else {
            targetCalendar = store.defaultCalendarForNewEvents
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
    
    func add(shift: Shift, at date: Date) throws {
        do {
            let event = EKEvent(eventStore: store)
            
            event.startDate = date
            event.endDate = date
            event.isAllDay = true
            event.title = shift.description
            event.calendar = targetCalendar!
            
            try store.save(event, span: EKSpan.thisEvent)
            NSLog("event saved: " + shift.description)
        } catch {
            NSLog("error occurred: " + shift.description)
        }
        
    }
    
    func remove(shift: Shift, at date: Date) throws {
        let predicate = store.predicateForEvents(withStart: date, end: date + 1.days(), calendars: [targetCalendar!])
        
        let events = store.events(matching: predicate)
        
        for event in events {
            if event.title == shift.description {
                try store.remove(event, span: .thisEvent)
            }
        }
    }
    



    func update(with shiftStorage:CalendarShiftStorage) throws {
        for (date,shifts) in shiftStorage {
            for shift in shifts {
                try add(shift: shift, at: date)
            }
        }
    }
}
