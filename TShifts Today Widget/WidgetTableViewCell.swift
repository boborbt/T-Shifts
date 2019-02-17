//
//  File.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 13/11/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit
import TShiftsFramework
import os.log

class WidgetTableViewCell:UITableViewCell {
    @IBOutlet var dayLabel: UILabel?
    @IBOutlet var shiftsLabel: UILabel?
    static var formatter: DateFormatter?
    
    func set(day:Date, shifts:[Shift]) {
        if WidgetTableViewCell.formatter == nil {
            WidgetTableViewCell.formatter = DateFormatter()
            WidgetTableViewCell.formatter?.dateFormat = "LLLL, d"
        }
        
        os_log(.debug, "Setting day %s", day.description)
        dayLabel?.text = WidgetTableViewCell.formatter?.string(from: day)
        
        shiftsLabel?.text = shifts.map({ (shift) -> String in
            return shift.description
        }).joined(separator: ", ")
    }
    
    
    override func awakeFromNib() {
    }
}
