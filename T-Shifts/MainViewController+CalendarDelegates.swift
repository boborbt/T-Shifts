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


extension MainViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
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
                                generateOutDates: .tillEndOfRow,
                                firstDayOfWeek: .monday)
        return parameters
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let dayCell = cell as! DayCellView
        dayCell.isEmphasized = cellState.isSelected
        dayCell.label.text = cellState.text
        
        if cellState.dateBelongsTo != .thisMonth {
            dayCell.prominence = .hidden
        } else if date.before(day:Date()) {
            dayCell.prominence = .dim
        } else {
            dayCell.prominence = .normal
        }
        
        let calendar = Calendar.current
        dayCell.isToday = calendar.isDateInToday(cellState.date)
        
        let shifts = shiftStorage.shifts(at: cellState.date)
        dayCell.marks = options.shiftTemplates.templates(for: shifts).compactMap({ $0 })
    }

    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "DayCellView", for: indexPath)
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }


    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath:IndexPath) {
        guard cellState.dateBelongsTo == .thisMonth else {
            // The only way the user can select a day past this month if it added a
            // shift to the last day on the month, which triggers a day selection of date + 1.days()
            // In that case we roll back the date selection by selecting the previous day
            calendar.selectDates([date - 1.days()])
            return
        }
        dayInfoView.show(date: date)

        guard let dayCell = cell as? DayCellView else { return }
        dayCell.isEmphasized = true
    }

    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let dayCell = cell as? DayCellView else { return }

        dayCell.isEmphasized = false
    }

    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        let monthYearText = dateFormatter.string(from: visibleDates.monthDates.first!.date)
        monthLabel.text = monthYearText.capitalized


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

    func calendar(shouldSelectDate date: Date, cell: JTACDayCell, cellState: CellState) -> Bool {
        return cellState.dateBelongsTo == .thisMonth
    }
}
