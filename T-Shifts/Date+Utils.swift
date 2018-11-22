//
//  NSDateExtension.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 27/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

extension Date {
    func firstDayOfMonth() -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var comp = components()
        comp.day = 1
        return calendar.date(from: comp)!
    }
    
    func sameMonth(as date: Date) -> Bool {
        return self.components().month == date.components().month
    }
    
    func sameDay(as date: Date) -> Bool {
        return self.components() == date.components()
    }
    
    func before(day: Date) -> Bool {
        let myComps = self.components()
        let dayComps = day.components()
        
        return myComps.year! < dayComps.year! ||
               myComps.year! == dayComps.year! && myComps.month! < dayComps.month! ||
               myComps.year! == dayComps.year! && myComps.month! == dayComps.month! && myComps.day! < dayComps.day!
    }
    

    func components() -> DateComponents {
        let date = self as Date
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        return calendar.components([.year, .month, .day], from: date)
    }
    
    static func date(from comp: DateComponents) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        return calendar.date(from: comp)!
    }
    
    static func date(from: Date, byAdding numDays:Int) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)
        return calendar!.date(byAdding: .day , value: numDays, to: Date())!
    }
    
    static func dateFromToday(byAdding numDays:Int) -> Date {
        return date(from: Date(), byAdding: numDays)
    }
    
    static func today() -> Date {
        return Date()
    }
    
    static func yesterday() -> Date {
        return dateFromToday(byAdding: -1)
    }
    
    static func tomorrow() -> Date {
        return dateFromToday(byAdding: 1)
    }
}
