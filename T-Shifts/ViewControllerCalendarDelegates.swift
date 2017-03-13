//
//  CalendarDelegates.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 09/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import JTAppleCalendar
import os.log


extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2000 01 01")!
        let endDate = formatter.date(from:"2100 01 01")!
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 5, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .off,
            firstDayOfWeek: .monday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let dayCell = cell as! DayCellView
        let calendar = Calendar.current
        
        dayCell.isEmphasized = cellState.isSelected
        dayCell.isInCurrentMonth = cellState.dateBelongsTo == .thisMonth
        dayCell.isToday = calendar.isDateInToday(cellState.date)
        
        dayCell.label.text = cellState.text
        let shifts = shiftStorage.shifts(at: cellState.date)
        dayCell.marks = options.shiftTemplates.templates(for: shifts).flatMap({ $0 })
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {

        dayInfoView.show(date: date)
        
        guard let dayCell = cell as? DayCellView else { return }
        dayCell.isEmphasized = true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let dayCell = cell as? DayCellView else { return }
        
        dayCell.isEmphasized = false
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: visibleDates.monthDates.first!)
//        let cal = Calendar.current
//        let isCurrentMonth = visibleDates.monthDates.index( where: { day in
//            return cal.isDateInToday(day)
//        })
        
//        if isCurrentMonth != nil {
//            calendar.selectDates([Date()])
//        } else {
//            calendar.selectDates([visibleDates.monthDates.first!])
//        }
        
//
    }

}
