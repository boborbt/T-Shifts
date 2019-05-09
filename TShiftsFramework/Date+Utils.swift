//
//  NSDateExtension.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 27/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

extension Date {
    public func firstDayOfMonth() -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var comp = components()
        comp.day = 1
        return calendar.date(from: comp)!
    }
    
    public func sameMonth(as date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .month) == .orderedSame
//        return self.components().month == date.components().month
    }
    
    public func sameDay(as date: Date) -> Bool {
        return Calendar.current.compare(self, to: date, toGranularity: .day) == .orderedSame
//        return self.components() == date.components()
    }
    
    public func before(day: Date) -> Bool {
        return Calendar.current.compare(self, to: day, toGranularity: .day) == .orderedAscending
        
//        let myComps = self.components()
//        let dayComps = day.components()
//
//        return myComps.year! < dayComps.year! ||
//               myComps.year! == dayComps.year! && myComps.month! < dayComps.month! ||
//               myComps.year! == dayComps.year! && myComps.month! == dayComps.month! && myComps.day! < dayComps.day!
    }
    

    public func components() -> DateComponents {
//        let date = self as Date
//        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
//        return calendar.components([.year, .month, .day], from: date)
        return Calendar.current.dateComponents([.year, .month, .day], from: self)
    }
    
    public static func date(from comp: DateComponents) -> Date {
        return Calendar.current.date(from: comp)!
//        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
//        return calendar.date(from: comp)!
    }
    
    public static func date(from: Date, byAdding numDays:Int) -> Date {
        return Calendar.current.date(byAdding: .day , value: numDays, to: from)!
    }
    
    public static func dateFromToday(byAdding numDays:Int) -> Date {
        return date(from: Date(), byAdding: numDays)
    }
    
    public static func today() -> Date {
        return Date()
    }
    
    public static func yesterday() -> Date {
        return dateFromToday(byAdding: -1)
    }
    
    public static func tomorrow() -> Date {
        return dateFromToday(byAdding: 1)
    }
    
    public static func beginningOfDay(_ date:Date) -> Date {
        var components = DateComponents()
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)

        components.day = day
        components.month = month
        components.year = year
        components.hour = 0
        components.minute = 0
        components.second = 1
        
        return Calendar.current.date(from: components)!
    }
    
    public static func endOfDay(_ date:Date) -> Date {
        var components = DateComponents()
        let day = Calendar.current.component(.day, from: date)
        let month = Calendar.current.component(.month, from: date)
        let year = Calendar.current.component(.year, from: date)
        
        components.day = day
        components.month = month
        components.year = year
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        return Calendar.current.date(from: components)!
    }
}
