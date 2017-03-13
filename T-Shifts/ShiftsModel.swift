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
    var storage: [ShiftTemplate] = []
    
    var count: Int {
        get {
            return storage.count
        }
    }
    
    var activesCount: Int {
        get {
            return storage.map { template in
                    template.shift.isActive ? 1 : 0
                }.reduce(0, { sum,val in
                    return sum + val
                })
        }
    }
    
    func template(for shift: Shift) -> ShiftTemplate? {
        return storage.first(where: { template in template.shift.shortcut == shift.shortcut })
    }
    
    func templates() -> [ShiftTemplate] {
        return storage
    }
    
    func templates(for shifts: [Shift]) -> [ShiftTemplate?] {
        return shifts.map { (shift) -> ShiftTemplate? in
            return template(for: shift)
        }
    }
    
    func template(at position: Int) -> ShiftTemplate? {
        return storage.first(where: { template in template.position == position })
    }
    
    func template(havingDescription description:String) -> ShiftTemplate? {
        return storage.first(where: { template in template.shift.description == description} )
    }
    
    // Assume that currentSet contains all distinct sc candidates and that
    // currentSet[i] is the candidate for descriptions[i]
    func computeShortcuts(descriptions: [String], currentSet: [String]) -> [String]? {
        if currentSet.count == descriptions.count {
            return currentSet
        }
        
        let currentPos = currentSet.count
        let currentDes = descriptions[currentPos]
        let size = currentDes.characters.count
        let desStart = currentDes.startIndex
        
        for i in 0..<size {
            let candidate = String(currentDes.characters[currentDes.index(desStart, offsetBy:i)])
            if currentSet.index(of: candidate) != nil {
                continue
            }
            
            if let solution = computeShortcuts(descriptions: descriptions, currentSet: currentSet + [candidate]) {
                return solution
            }
        }
        
        return nil
    }
    
    func recomputeShortcuts() {
        let data = storage.enumerated().flatMap( { (index,template) -> (Int, String)? in
            let des = template.shift.description
            return des == "" ? nil : (index, template.shift.description)
        })
        
        let indexes = data.map { (index, description) in  return index }
        let descriptions = data.map { (index, description) in  return description }
        
        var shortcuts: [String]!
        
        if let candidates  = computeShortcuts(descriptions: descriptions, currentSet:[]) {
            shortcuts = candidates
        } else {
            shortcuts = indexes.map { index in return "\(index)" }
        }
        
        
        for (index, sc) in shortcuts.enumerated() {
            let templateIndex = indexes[index]
            storage[templateIndex].shift.shortcut = sc
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
        guard let targetCalendar = calendarUpdater.targetCalendar else { return [] }
        let store = calendarUpdater.store
        let predicate = store.predicateForEvents(withStart: date, end: date + 1.days(), calendars: [targetCalendar])
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
            guard targetCalendar != nil else { return }
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

    init(calendarName:String) {
        switchToCalendar(named: calendarName)
    }
    
    
    static func isAccessGranted() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }

    func switchToCalendar(named calendarName: String) {
        let calendar = store.calendars(for: .event).first(where: { calendar in calendar.title == calendarName})
        
        if calendar != nil {
            targetCalendar = calendar
        } else {
            targetCalendar = store.defaultCalendarForNewEvents
        }
    }
    
    
    func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        store.requestAccess(to: .event, completion: completion)
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
