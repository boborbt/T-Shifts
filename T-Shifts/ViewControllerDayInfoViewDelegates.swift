//
//  ViewControllerDayInfoViewDelegates.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 16/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

extension ViewController:  DayInfoViewDelegate {
    func dayInfoTapOn(shiftButton: MarkButton) {
        addShift(shiftButton)
    }
    
    func templates() -> ShiftTemplates {
        return options.shiftTemplates
    }
    
    func templatesForDate(date: Date) -> [ShiftTemplate] {
        let shifts = shiftStorage.shifts(at: date)
        let templates = options.shiftTemplates.templates(for: shifts).compactMap({ $0 })
        return templates
    }
    
}
