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
    

    func components() -> DateComponents {
        let date = self as Date
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        return calendar.components([.year, .month, .day], from: date)
    }
    
    static func date(from comp: DateComponents) -> Date {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        return calendar.date(from: comp)!
    }
}
