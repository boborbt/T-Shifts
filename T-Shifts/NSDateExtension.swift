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
        let date = self as Date
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        var comp = calendar.components([.year, .month, .day], from: date)
        
        comp.day = 1
        
        return calendar.date(from: comp)!
    }
}
