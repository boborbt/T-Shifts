//
//  DayCellView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 09/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import JTAppleCalendar
import TShiftsFramework

class DayCellView: JTACDayCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var selectionEmphasis: UIView!
    @IBOutlet weak var marksDisplayView: MarksDisplayView!
    
    enum ColorEmphasis {
        case normal
        case dim
        case hidden
    }
    
//   MARK: PROPERTIES
    
    var isToday: Bool = false {
        didSet {
            updateMarksColor()
            updateLabelColor()
        }
    }
    
    var colorEmphasis: ColorEmphasis = .normal {
        didSet {
            updateMarksColor()
            updateLabelColor()
        }
    }
    
    private var showEmphasis: Bool = false

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
    
// MARK: PUBLIC FUNCTIONS
    
    override func prepareForReuse() {
        resetUIToDefaults()
    }

    
//    MARK: PRIVATE FUNCTIONS
    
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
    
    private func resetUIToDefaults() {
        colorEmphasis = .normal
        isEmphasized = false
        isToday = false
        marks = []
        setNeedsDisplay()
    }

}
