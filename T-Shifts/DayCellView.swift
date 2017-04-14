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
    
    enum ColorEmphasis {
        case normal
        case dim
        case hidden
    }
    
    
    var isToday: Bool = false {
        didSet {
            updateMarksColor()
            updateLabelColor()
        }
    }
    
    var colorEmphasis: ColorEmphasis = .normal {
        didSet {
            updateLabelColor()
            updateMarksColor()
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
    
    
    private func updateMarksColor() {
        switch colorEmphasis {
        case .normal:
            self.alpha = 1.0
        case .dim:
            self.alpha = 0.3
        case .hidden:
            self.alpha = 0.0
        }
    }

    
    private func updateLabelColor() {        
        if isToday {
            label.textColor = UIColor.red
            return
        }
        
        label.textColor = UIColor.black
    }

}
