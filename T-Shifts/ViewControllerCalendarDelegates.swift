//
//  CalendarDelegates.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 09/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import JTAppleCalendar

class Colors {
    static let black = UIColor.black
    static let gray = UIColor.gray
    static let red = UIColor.red
}


extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2000 01 01")! // You can use date generated from a formatter
        let endDate = formatter.date(from:"2100 01 01")!                                // You can also use dates created from this function
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 5, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .monday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let dayCell = cell as! DayCellView
        let calendar = Calendar.current
        
        // Setup Cell text
        dayCell.label.text = cellState.text
        dayCell.isEmphasized = cellState.isSelected
        dayCell.isInCurrentMonth = cellState.dateBelongsTo == .thisMonth
        dayCell.isToday = calendar.isDateInToday(cellState.date)
        
        let shifts = shiftStorage.shifts(at: cellState.date)
        
        let templates: [ShiftTemplate] = shifts.map { (shift) -> ShiftTemplate in
            return shiftTemplates.template(for: shift)!
        }
        dayCell.marks = templates

        dayCell.updateAspect()
        
        if cellState.isSelected {
            dayInfoView.dayCell.copyAttributes(from: dayCell)
            dayInfoView.activateMarkButtons(templates: dayCell.marks)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let dayCell = cell as? DayCellView else { return }
        dayCell.isEmphasized = cellState.isSelected
        
        dayInfoView.dayCell.copyAttributes(from: dayCell)
        dayInfoView.activateMarkButtons(templates: dayCell.marks)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        guard let dayCell = cell as? DayCellView else { return }
        
        dayCell.isEmphasized = cellState.isSelected
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        MonthLabel.text = dateFormatter.string(from: visibleDates.monthDates.first!)
    }

}
