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

/**
   Properties and visualization of day cells in the calendar.
 
 In T-Shifts a day cell contains a list of colored marks that show which shifts have been set for each particular day and a label with the day number in the current month.
 
 The visualization depends on some properties of the current day and of the current state of the application:
 
    - if the day is earlier than today: all the appearence is dimmed;
    - if the day is selected, then the whole cell is highlighed
    - today label is rendered in a different color (currently it is red)
*/
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
            self.label.alpha = 1.0
            self.marksDisplayView.alpha = 1.0
        case .dim:
            self.label.alpha = 0.3
            self.marksDisplayView.alpha = 0.3
        case .hidden:
            self.label.alpha = 0.0
            self.marksDisplayView.alpha = 0.0
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
