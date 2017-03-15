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
        var startDateComponents = Date().components()
        startDateComponents.day = 1
        startDateComponents.month = 1
        startDateComponents.year! -= 2
        
        var endDateComponents = Date().components()
        endDateComponents.day = 31
        endDateComponents.month = 12
        endDateComponents.year! += 2
        
        let startDate = Date.date(from: startDateComponents)
        let endDate = Date.date(from: endDateComponents)
        let parameters =
            ConfigurationParameters(startDate: startDate,
                                endDate: endDate,
                                numberOfRows: 5,
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
        let monthYearText = dateFormatter.string(from: visibleDates.monthDates.first!)
        monthLabel.text = monthYearText
        
        
        if let selectedDate = calendar.selectedDates.first {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            let dayToSelectString = dayFormatter.string(from: selectedDate) + " " + monthYearText
            dayFormatter.dateFormat = "dd MMMM yyyy"
            
            if let dayToSelect = dayFormatter.date(from: dayToSelectString) {
                calendar.selectDates([dayToSelect])
            } else {
                calendar.selectDates([Date().firstDayOfMonth()])
            }
        }
    }

}
