//
//  DayCellView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 09/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import JTAppleCalendar

class DayCellView: JTAppleDayCellView {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectionEmphasis: UIView!
    @IBOutlet weak var marksDisplayView: MarksDisplayView!
    
    
    var isToday: Bool = false {
        didSet {
            updateLabelColor()
        }
    }
    
    var isInCurrentMonth: Bool = false {
        didSet {
            updateLabelColor()
        }
    }
    
    var showEmphasis: Bool = false
    var showTodayMark: Bool = false

    var marks: [ShiftTemplate] = [] {
        didSet {
            marksDisplayView.marks = marks
        }
    }
    
    var isEmphasized: Bool {
        get {
            return showEmphasis
        }
        
        set(newVal) {
            showEmphasis = newVal
            
            selectionEmphasis.layer.cornerRadius = 5
            selectionEmphasis.alpha = newVal ? 1.0 : 0.0
        }
    }
    
    

    
    private func updateLabelColor() {
        if !isInCurrentMonth {
            label.textColor = UIColor.gray
            return
        }
        
        if isToday {
            label.textColor = UIColor.red
            return
        }
        
        label.textColor = UIColor.black
    }

}
