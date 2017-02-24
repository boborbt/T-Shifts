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
import os.log

// A Shift contains the informations needed to describe a shift
// - a description and a shortcut
//
// Shift needs to be hashable and equatable by the shortcut only
// i.e. the shortcut need to be a unique identifier for a shift "value"
struct Shift: Equatable, Hashable {
    public var hashValue: Int {
        get {
            return shortcut.hashValue
        }
    }

    static func == (lhs: Shift, rhs: Shift) -> Bool {
        return lhs.shortcut == rhs.shortcut
    }
    
    var description: String
    var shortcut: String
    
    var isActive: Bool {
        get {
            return description != ""
        }
    }
}

// A shift storage provides a mean to store shifts. The main
// implementation will be based on the system calendar, but
// other storage are conceivable.
//
// In the storage shifts are associated with dates. Each date
// can contain zero or more shifts (with no limits imposed by
// the storate -- they may be imposed by the UI though).
protocol ShiftStorage: Sequence {
    // Adds the given shift at the given date. It does not check
    // if the shift is already present at the given date (the user
    // can check it using the isPresent method).
    func add(shift: Shift, toDate: Date) throws
    
    // Removes the shift from the given date. The shift must be present
    // at the given date.
    func remove(shift:Shift, fromDate: Date) throws
    
    // Returns true if the given shift is already present at the given date
    func isPresent(shift: Shift, at date: Date) -> Bool
    
    // Returns the set of shifts at the given date
    func shifts(at date: Date) -> [Shift]
    
    // tells the storage to notify any add/remove operation to the caller
    // using the provided function.
    func notifyChanges(to function:@escaping (Date)->() )
}


// A shift template associate a shift with additional properties
// that are important to the UI such as the color for displaying it
// and its position in the visualization grid.
struct ShiftTemplate {
    var shift: Shift
    var position: Int
    var color: UIColor
}


// ShiftTemplates is presently nothing more than a wrapper around
// a collection of shift templates. Its main purpose is to provide
// easy access to common functions.
class ShiftTemplates {
    var templates: [ShiftTemplate] = []
    
    var count: Int {
        get {
            return templates.count
        }
    }
    
    var activesCount: Int {
        get {
            return templates.map { template in
                    template.shift.isActive ? 1 : 0
                }.reduce(0, { sum,val in
                    return sum + val
                })
        }
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
    
    func updateTemplate(at position: Int, newTemplate: ShiftTemplate) {
        let index = templates.index( where: { t in return t.position ==  position })!
        templates[index] = newTemplate
        
        recomputeShortcuts()
    }
    
    func computeShortcut(at pos: Int) -> String? {
        guard templates[pos].shift.description != "" else { return "" }
        let des = templates[pos].shift.description
        var offset = 0
        var result = String(des.characters[des.index(des.startIndex, offsetBy: offset)])
        
        while offset < des.characters.count {
            let found = templates.index( where: { t in t.shift.shortcut == result }) != nil
            if !found {
                return result
            }
            offset += 1
            result = String(des.characters[des.index(des.startIndex, offsetBy: offset)])
        }
        
        
        return nil
        
    }
    
    func recomputeShortcuts() {
        for i in 0 ..< templates.count {
            templates[i].shift.shortcut = ""
        }
        
        for i in 0 ..< templates.count {
            templates[i].shift.shortcut = computeShortcut(at:i)!
        }
    }
}

// A shift storage based on the system calendar.
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
            return self.shiftTemplates.template(havingDescription: description)?.shift
        })
    }
    
    func makeIterator() -> DictionaryIterator<Date,[Shift]> {
        return [:].makeIterator()
    }
    
    func notifyChanges(to function: @escaping (Date) -> ()) {
        callback = function
    }

}

// A shift storage that stores the shifts only in memory. Useful for debugging 
// purposes (it was also the base of the old implementation)

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


// This class incapsulate the interaction with the system calendar
// library. It simplifies the code by providing an easier interface
// to the most used calendar functionalities.

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
                    os_log("Not granted")
                } else {
                    os_log("Error")
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
            os_log("event saved: ", shift.description)
        } catch {
            os_log("error occurred: ",  shift.description)
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
