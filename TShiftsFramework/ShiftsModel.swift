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


public typealias AlertInfo = (active: Bool, minutes: Int)
public typealias ShiftTime = (hour:Int, minute: Int)

// MARK: TYPE DEFINITIONS

/// A Shift contains the informations needed to describe a shift
///
/// Shift needs to be hashable and equatable by the shortcut only
/// i.e. the shortcut need to be a unique identifier for a shift "value"
public struct Shift: Equatable, Hashable {

    /// textual description of the shift itself
    public var description: String
    
    /// the shortcut used to identify the shift
    public var shortcut: String
    
    /// true if the shift needs to be visualised as an all-day event
    public var isAllDay: Bool
    
    /// if `isAllDay` is false, this property specify the time at which the shift begins
    public var startTime:  ShiftTime
    
    /// if `isAllDay` is false, this property specify the time at which the shift ends
    public var endTime: ShiftTime
    
    /// if `isAllDay` is false, this property allows to set an alarm that fires at a given time before `startTime`
    public var alert: AlertInfo
    
    
    public init() {
        self.init(description: "", shortcut: "", isAllDay: true, startTime: (8,0), endTime:(16,0), alert:(active:false, minutes:-60))
    }
    
    public init(description: String, shortcut: String, isAllDay: Bool, startTime: ShiftTime, endTime:ShiftTime, alert: AlertInfo ) {
        self.description = description
        self.shortcut = shortcut
        self.isAllDay = isAllDay
        self.startTime = startTime
        self.endTime = endTime
        self.alert = alert;
    }
    
    /// Returns true if this shift has to be considered as active (presently this coincides with having a non-empty description)
    public var isActive: Bool {
        get {
            return description != ""
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(shortcut)
    }
    
    public static func == (lhs: Shift, rhs: Shift) -> Bool {
        return lhs.shortcut == rhs.shortcut
    }
}

/// A shift storage provides a mean to store shifts.
///
/// The main implementation will be based on the system calendar, but
/// other storage types are conceivable.
///
/// In the storage shifts are associated with dates. Each date
/// can contain zero or more shifts (with no limits imposed by
/// the storate -- they may be imposed by the UI though).
public protocol ShiftStorage {
    /// Adds the given shift at the given date. It does not check
    /// if the shift is already present at the given date (the user
    /// can check it using the isPresent method).
    func add(shift: Shift, toDate: Date) throws
    
    /// Removes the shift from the given date. The shift must be present
    /// at the given date.
    func remove(shift:Shift, fromDate: Date) throws
    
    /// Remove
    func commit() throws -> [Date]
    
    /// Returns true if the given shift is already present at the given date
    func isPresent(shift: Shift, at date: Date) -> Bool
    
    /// Returns the set of shifts at the given date
    func shifts(at date: Date) -> [Shift]
    
    /// tells the storage to notify any add/remove operation to the caller
    /// using the provided function.
    func notifyChanges(to function:@escaping (Date)->() )
    
    /// Returns a human readable description of the shifts at the given date
    func shiftsDescription(at date: Date) -> String?
    
    /// Returns a unique identifier for the shifts data at the given date
    func uniqueIdentifier(for date: Date) -> String
    
    /// Returns the date associated to the given unique identifier
    func date(forUniqueIdentifier identifier:String) -> Date?
}


/// A shift template associate a shift with additional properties
/// that are important to the UI such as the color for displaying it
/// and its position in the visualization grid.
///
/// # properties
///   - shift: the shift description
///   - position: the position among the templates
///   - color: the color in which the template has to be rendered
public struct ShiftTemplate {
    /// the shift description
    public var shift: Shift
    /// the position among the templates
    public var position: Int
    /// the color that has to be used to render the tamplate
    public var color: UIColor
}


/// ShiftTemplates is  a collection of shift templates.
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
    
    /// Given the current set of shortcut candidates tries to complete the set by adding the missing ones (assumes that the ones
    /// computed up to now cannot be modified).
    ///
    /// Assume that currentSet contains all distinct sc candidates and that currentSet[i] is the candidate for descriptions[i]
    ///
    /// - returns:
    /// An array containing the computed shortcut list or nil if the list cannot be created (no combination of letters in the remaining
    /// descritption allows for creating unique identifiers).
    ///
    /// - parameters:
    ///     - descriptions: the list of description to be used as a base for the shortcuts;
    ///     - currentSet: the current list of shortcuts. It assumes that the list is a valid one (all elements are unique and currentSet[i] is the candidate for descriptions[i])
    private func computeShortcuts(descriptions: [String], currentSet: [String]) -> [String]? {
        if currentSet.count == descriptions.count {
            return currentSet
        }
        
        let currentPos = currentSet.count
        let currentDes = descriptions[currentPos]
        let size = currentDes.count
        let desStart = currentDes.startIndex
        
        for i in 0..<size {
            let candidate = String(currentDes[currentDes.index(desStart, offsetBy:i)])
            if currentSet.firstIndex(of: candidate) != nil {
                continue
            }
            
            if let solution = computeShortcuts(descriptions: descriptions, currentSet: currentSet + [candidate]) {
                return solution
            }
        }
        
        return nil
    }
    
    /// Computes a list of single letter identifiers for the set of shift descriptions stored in the ShiftTemplates collection
    ///
    /// The function tries to find meaningful and unique identifiers:
    ///    - meaningful here means that it tries to use one of the first letters of the description (so "Morning" would get, if possible, a "M" shortcut)
    ///    - uniqueness is guaranteed by moving down the list of possible identifiers until a unique shortcut is found. If two descriptions are identical a numerical index is assigned.
    ///
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


// MARK: CALENDAR ACCESS

// A shift storage based on the system calendar.
// Supports events coalescence.
public class CalendarShiftStorage : ShiftStorage {
    
    // Type used to record the kind of change requested
    enum ShiftUpdate {
        case add(Shift, Date)
        case remove(Shift, Date)

        static func ==(lhs:ShiftUpdate, rhs:ShiftUpdate) -> Bool {
            switch(lhs, rhs) {
            case let (.add(shift1,date1), .add(shift2,date2)),
                 let (.remove(shift1,date1), .remove(shift2,date2)):
                return shift1 == shift2 && Calendar.current.compare(date1, to:date2, toGranularity: .day) == .orderedSame
            default:
                return false
            }
            
        }
    }
    
    var callback: ((Date) -> ())!
    let formatter: DateFormatter!
    public weak var shiftTemplates: ShiftTemplates!
    weak var calendarUpdater: CalendarShiftUpdater!
    var requestedUpdates: [ShiftUpdate]
    
    public init(updater: CalendarShiftUpdater, templates: ShiftTemplates) {
        calendarUpdater = updater
        shiftTemplates = templates
        formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        requestedUpdates = []
    }
    
    public func add(shift: Shift, toDate date: Date) throws {
        requestedUpdates.removeAll { update in update == .remove(shift, date) }
        requestedUpdates.append(.add(shift, date))
        callback(date)
    }
    
    public func remove(shift:Shift, fromDate date: Date) throws {
        requestedUpdates.removeAll { update in update == .add(shift, date) }
        requestedUpdates.append(.remove(shift, date))
        callback(date)
    }
    
    public func commit() throws -> [Date]  {
        var changedDates:[Date] = []
        for update in requestedUpdates {
            switch update {
            case .add(let shift, let date):
                try calendarUpdater.add(shift: shift, at: date)
                changedDates.append(date)
            case .remove(let shift, let date):
                try calendarUpdater.remove(shift: shift, at: date)
                changedDates.append(date)
            }
        }
        try calendarUpdater.commit()
        
        requestedUpdates = []
        
        return changedDates
    }
    
    public func isPresent(shift: Shift, at date: Date) -> Bool  {
        let shifts = self.shifts(at: date)
        return shifts.firstIndex(where: { s in shift == s }) != nil
    }
    
    public func shifts(at givenDate: Date) -> [Shift] {
        guard let targetCalendar = calendarUpdater.targetCalendar else { return [] }
        let startDate = Date.beginningOfDay(givenDate)
        let endDate = Date.endOfDay(givenDate)
        let store = calendarUpdater.store
        let predicate = store.predicateForEvents(withStart: startDate, end: endDate, calendars: [targetCalendar])
        let events = calendarUpdater.store.events(matching: predicate)
        
        var result:[Shift] = events.compactMap({ (event) in
            guard Calendar.current.compare(event.startDate, to:givenDate, toGranularity: .day) == .orderedSame else {
                return nil
            }
            let description = event.title
            return self.shiftTemplates.template(havingDescription: description!)?.shift
        })
        
        for update in requestedUpdates {
            switch update {
            case .add(let s, let d):
                if Calendar.current.compare(d, to: givenDate, toGranularity: .day) == .orderedSame {
                    result.append(s)
                }
            case .remove(let s, let d):
                if Calendar.current.compare(d, to: givenDate, toGranularity: .day) == .orderedSame {
                    result.removeAll(where: { shift in s == shift })
                }
            }
        }
        
        // It might happen that the user requests both the removal and the addition of a shift.
        // In this case the calendar will still have the event, and the requestUpdates would contain
        // the request for addition. This would make result to contain a duplicate of the given shift.
        // We then remove duplicates from the list before returning it.
        return Array(Set(result))
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
    
    
    private func dateComponentsFor(date:Date, time:(hour:Int,minute:Int)) -> DateComponents {
        let cal = Calendar.current
        var dc = DateComponents()
        dc.day = cal.component(.day, from: date)
        dc.month = cal.component(.month, from: date)
        dc.year = cal.component(.year, from: date)
        dc.hour = time.hour
        dc.minute = time.minute
        
        return dc
    }
    
    private func startEndDateFor(shift:Shift, date:Date) -> (Date, Date) {
        if shift.isAllDay {
            return (date, date)
        }
        
        let cal = Calendar.current
        let startDate = cal.date(from:dateComponentsFor(date: date, time: shift.startTime))!
        var endDate = cal.date(from:dateComponentsFor(date: date, time: shift.endTime))!
        
        if startDate > endDate {
            endDate = cal.date(byAdding: .day, value: 1, to: endDate)!
        }
        
        return (startDate, endDate)
    }
    
    public func add(shift: Shift, at date: Date) throws {
        do {
            let event = EKEvent(eventStore: store)
            let (startDate, endDate) = startEndDateFor(shift: shift, date: date)
            
            event.startDate = startDate
            event.endDate = endDate
            event.isAllDay = shift.isAllDay
            event.title = shift.description
            event.calendar = targetCalendar!
            
            if !shift.isAllDay && shift.alert.active {
                event.addAlarm(EKAlarm(relativeOffset: TimeInterval(-60 * shift.alert.minutes)))
            }
            
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
