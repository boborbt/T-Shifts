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
        
        let startDate = formatter.date(from: "2017 02 01")! // You can use date generated from a formatter
        let endDate = Date()                                // You can also use dates created from this function
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
        
        // Setup Cell text
        dayCell.label.text = cellState.text
        
        // Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            dayCell.label.textColor = Colors.black
        } else {
            dayCell.label.textColor = Colors.gray
        }
        
        let calendar = Calendar.current
        
        
        dayCell.isToday = calendar.isDateInToday(cellState.date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        let dayCell = cell as! DayCellView
        
        dayCell.mark1.isHidden = false
        
        dayCell.selectionEmphasis.layer.cornerRadius =  5
        
        // Let's make the view have rounded corners. Set corner radius to 25
        
        if cellState.isSelected {
            UIView.animate(withDuration: 0.5, animations: {
                dayCell.selectionEmphasis.alpha = 1.0
            })
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        let dayCell = cell as! DayCellView
        
        UIView.animate(withDuration: 0.5, animations: {
            dayCell.selectionEmphasis.alpha = 0.0
        })
    }

}
