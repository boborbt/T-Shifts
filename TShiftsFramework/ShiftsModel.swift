//
//  ShiftsModel.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import EventKit
import os.log

// A Shift contains the informations needed to describe a shift
// - a description and a shortcut
//
// Shift needs to be hashable and equatable by the shortcut only
// i.e. the shortcut need to be a unique identifier for a shift "value"
public struct Shift: Equatable, Hashable {
    public var hashValue: Int {
        get {
            return shortcut.hashValue
        }
    }

    public static func == (lhs: Shift, rhs: Shift) -> Bool {
        return lhs.shortcut == rhs.shortcut
    }
    
    public var description: String
    public var shortcut: String
    
    public var isActive: Bool {
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
public protocol ShiftStorage {
    // Adds the given shift at the given date. It does not check
    // if the shift is already present at the given date (the user
    // can check it using the isPresent method).
    func add(shift: Shift, toDate: Date) throws
    
    // Removes the shift from the given date. The shift must be present
    // at the given date.
    func remove(shift:Shift, fromDate: Date) throws
    
    // Remove
    func commit() throws
    
    // Returns true if the given shift is already present at the given date
    func isPresent(shift: Shift, at date: Date) -> Bool
    
    // Returns the set of shifts at the given date
    func shifts(at date: Date) -> [Shift]
    
    // tells the storage to notify any add/remove operation to the caller
    // using the provided function.
    func notifyChanges(to function:@escaping (Date)->() )
    
    // Returns a human readable description of the shifts at the given date
    func shiftsDescription(at date: Date) -> String?
    
    // Returns a unique identifier for the shifts data at the given date
    func uniqueIdentifier(for date: Date) -> String
    
    // Returns the date associated to the given unique identifier
    func date(forUniqueIdentifier identifier:String) -> Date?
}


// A shift template associate a shift with additional properties
// that are important to the UI such as the color for displaying it
// and its position in the visualization grid.
public struct ShiftTemplate {
    public var shift: Shift
    public var position: Int
    public var color: UIColor
}


// ShiftTemplates is presently nothing more than a wrapper around
// a collection of shift templates. Its main purpose is to provide
// easy access to common functions.
public class ShiftTemplates {
    public var storage: [ShiftTemplate] = []
    
    public var count: Int {
        get {
            return storage.count
        }
    }
    
    public var activesCount: Int {
        get {
            return storage.map { template in
                    template.shift.isActive ? 1 : 0
                }.reduce(0, { sum,val in
                    return sum + val
                })
        }
    }
    
    public func template(for shift: Shift) -> ShiftTemplate? {
        return storage.first(where: { template in template.shift.shortcut == shift.shortcut })
    }
    
    public func templates() -> [ShiftTemplate] {
        return storage
    }
    
    public func templates(for shifts: [Shift]) -> [ShiftTemplate?] {
        return shifts.map { (shift) -> ShiftTemplate? in
            return template(for: shift)
        }
    }
    
    public func template(at position: Int) -> ShiftTemplate? {
        return storage.first(where: { template in template.position == position })
    }
    
    public func template(havingDescription description:String) -> ShiftTemplate? {
        return storage.first(where: { template in template.shift.description == description} )
    }
    
    // Assume that currentSet contains all distinct sc candidates and that
    // currentSet[i] is the candidate for descriptions[i]
    public func computeShortcuts(descriptions: [String], currentSet: [String]) -> [String]? {
        if currentSet.count == descriptions.count {
            return currentSet
        }
        
        let currentPos = currentSet.count
        let currentDes = descriptions[currentPos]
        let size = currentDes.count
        let desStart = currentDes.startIndex
        
        for i in 0..<size {
            let candidate = String(currentDes[currentDes.index(desStart, offsetBy:i)])
            if currentSet.index(of: candidate) != nil {
                continue
            }
            
            if let solution = computeShortcuts(descriptions: descriptions, currentSet: currentSet + [candidate]) {
                return solution
            }
        }
        
        return nil
    }
    
    public func recomputeShortcuts() {
        let data = storage.enumerated().compactMap( { (__val:(Int, ShiftTemplate)) -> (Int, String)? in let (index,template) = __val;
            let des = template.shift.description
            return des == "" ? nil : (index, template.shift.description)
        })
        
        let indexes = data.map { elem -> Int in  let (index, _ ) = elem;  return index }
        let descriptions = data.map { elem -> String in   let (_, description) = elem;  return description }
        
        var shortcuts: [String]!
        
        if let candidates  = computeShortcuts(descriptions: descriptions, currentSet:[]) {
            shortcuts = candidates
        } else {
            shortcuts = indexes.map { index in return "\(index)" }
        }
        
        for index in 0 ..< storage.count {
            storage[index].shift.shortcut = ""
        }
        
        for (index, sc) in shortcuts.enumerated() {
            let templateIndex = indexes[index]
            storage[templateIndex].shift.shortcut = sc
        }
    }
    
    
}

// A shift storage based on the system calendar.

// TODO: Add some kind of temporary storage to collect shifts not yet committed.
//    The storage should be updated to add new shifts or to remove ones.
//    Note that when removing a shift, one needs first to check if the shift
//    is in the temporary storage (it can be deleted from there if it is), if
//    not the deletion should be recorded in the storage.
//
//    This complicates things, for instance when adding a shift, one should also
//    check if the tmp storage does not already contain that shift (the change
//    should be ignored in that case) or if the tmp storage do not containe a
//    deletion of that shift (the deletion should be removed and the addition
//    should be scheduled).
public class CalendarShiftStorage : ShiftStorage, Sequence {
    var callback: ((Date) -> ())!
    let formatter: DateFormatter!
    public weak var shiftTemplates: ShiftTemplates!
    weak var calendarUpdater: CalendarShiftUpdater!
    
    public init(updater: CalendarShiftUpdater, templates: ShiftTemplates) {
        calendarUpdater = updater
        shiftTemplates = templates
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
    public func add(shift: Shift, toDate date: Date) throws {
        try calendarUpdater.add(shift: shift, at: date)
        callback(date)
    }
    
    public func commit() throws {
        try calendarUpdater.commit()
    }
    
    public func remove(shift:Shift, fromDate date: Date) throws {
        try calendarUpdater.remove(shift: shift, at: date)
        callback(date)
    }
    
    public func isPresent(shift: Shift, at date: Date) -> Bool  {
        let shifts = self.shifts(at: date)
        return shifts.index(where: { s in shift == s }) != nil
    }
    
    public func shifts(at date: Date) -> [Shift] {
        guard let targetCalendar = calendarUpdater.targetCalendar else { return [] }
        let store = calendarUpdater.store
        let predicate = store.predicateForEvents(withStart: date, end: date + 1, calendars: [targetCalendar])
        let events = calendarUpdater.store.events(matching: predicate)
        
        return events.compactMap({ (event) in
            let description = event.title
            return self.shiftTemplates.template(havingDescription: description!)?.shift
        })
    }
    
    public func makeIterator() -> DictionaryIterator<Date,[Shift]> {
        return [:].makeIterator()
    }
    
    public func notifyChanges(to function: @escaping (Date) -> ()) {
        callback = function
    }
    
    public func shiftsDescription(at date: Date) -> String? {
        let shifts = self.shifts(at: date)
        
        if shifts.isEmpty {
            return nil
        }
        
        let descriptions: [String] = shifts.map() { s in s.description }
        return descriptions.joined(separator:" ")
    }
    
    public func uniqueIdentifier(for date: Date) -> String {
        return "Shifts:\(formatter.string(from: date))"
    }

    public func date(forUniqueIdentifier identifier: String) -> Date? {
        let stringComponents = identifier.components(separatedBy: ":")
        
        if stringComponents.count != 2 {
            return nil
        }
        
        return formatter.date(from:stringComponents[1])
    }

}

// A shift storage that stores the shifts only in memory. Useful for debugging 
// purposes (it was also the base of the old implementation)

class LocalShiftStorage: ShiftStorage, Sequence {
    var storage: [Date:[Shift]] = [:]
    var callback: ((Date) -> ())!
    let formatter: DateFormatter!
    
    init() {
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
    }
    
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
    
    func commit() throws {
        
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
    
    func shiftsDescription(at date: Date) -> String? {
        let shifts = self.shifts(at: date)
        
        if shifts.isEmpty {
            return nil
        }
        
        let shortcuts: [String] = shifts.map() { s in s.description }
        return shortcuts.joined(separator:" ")
    }
    
    func uniqueIdentifier(for date: Date) -> String {
        return "Shifts:\(formatter.string(from: date))"
    }
    
    func date(forUniqueIdentifier identifier: String) -> Date? {
        let stringComponents = identifier.components(separatedBy: ":")
        
        if stringComponents.count != 2 {
            return nil
        }
        
        return formatter.date(from:stringComponents[1])
    }
}


// This class incapsulate the interaction with the system calendar
// library. It simplifies the code by providing an easier interface
// to the most used calendar functionalities.

public class CalendarShiftUpdater {
    var store = EKEventStore()
    var calendarUpdateCallback: (EKCalendar)->()
    public var targetCalendar: EKCalendar? {
        didSet {
            guard let targetCalendar = targetCalendar else { return }
            
            calendarUpdateCallback(targetCalendar)
        }
    }

    public var calendars: [EKCalendar] {
        get {
            // FIXME: This should return a list of calendars filtered
            //   so to filter out non editable calendars
            return store.calendars(for: .event).filter { calendar in !calendar.isImmutable }
        }
    }

    public init(calendarName:String, calendarUpdateCallback callback:@escaping (EKCalendar)->()) {
        calendarUpdateCallback = callback
        switchToCalendar(named: calendarName)
    }
    
    
    public static func isAccessGranted() -> Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }

    public func switchToCalendar(named calendarName: String) {
        let calendar = store.calendars(for: .event).first(where: { calendar in calendar.title == calendarName})
        
        if calendar != nil {
            targetCalendar = calendar
        } else {
            targetCalendar = store.defaultCalendarForNewEvents
        }
    }
    
    
    public func requestAccess(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        store.requestAccess(to: .event, completion: { granted, error in
            // refreshing the store
            self.store = EKEventStore()
            completion(granted, error)
        })
    }
    
    public func add(shift: Shift, at date: Date) throws {
        do {
            let event = EKEvent(eventStore: store)
            
            event.startDate = date
            event.endDate = date
            event.isAllDay = true
            event.title = shift.description
            event.calendar = targetCalendar!
            
            try store.save(event, span: EKSpan.thisEvent, commit: false)
            os_log(.debug, "Shift saved to Calendar store: %@", shift.description)
        } catch let error {
            os_log(.error, "Error (%@) occurred for shift: %@", [error, shift.description])
        }
        
    }
    
    public func commit() throws  {
        do {
            try store.commit()
        } catch let error {
            os_log(.debug, "Cannot commit changes to the store, reason: %@", [error])
        }
    }
    
    public func remove(shift: Shift, at date: Date) throws {
        let predicate = store.predicateForEvents(withStart: date, end: date + 1.days(), calendars: [targetCalendar!])
        
        let events = store.events(matching: predicate)
        
        for event in events {
            if event.title == shift.description {
                try store.remove(event, span: .thisEvent)
            }
        }
    }
    

}
