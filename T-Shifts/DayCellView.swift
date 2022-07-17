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
    
    var showBorder = false
    
    /// Describe the emphasis level of cells
    enum ColorProminence {
        /// default level, no emphasis, no dimming
        case normal
        /// the cell is dimmed so to appear less prominent
        case dim
        /// the cell is totally hidden
        case hidden
    }
    
//   MARK: PROPERTIES
    
    /// controls how the cell is rendered, set it to `true` to render it as as the "today" cell.
    var isToday: Bool = false {
        didSet {
            updateMarksColor()
            updateLabelColor()
        }
    }
    
    /// controls how the cell is rendered, set it to either `.dim`, `.hidden`, or `normal`
    var prominence: ColorProminence = .normal {
        didSet {
            updateMarksColor()
            updateLabelColor()
        }
    }
    
    /// controls the shift marks that are rendered on the cell
    ///
    /// Each shift template will be rendered as a colored mark in the cell.
    var marks: [ShiftTemplate] = [] {
        didSet {
            marksDisplayView.marks = marks
        }
    }
    
    private var showEmphasis: Bool = false

    /// controls whether the cell is highlighted
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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if showBorder {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 9)
            UIColor.lightGray.set()
            path.stroke()
        }
    }
    
// MARK: PUBLIC FUNCTIONS
    
    override func prepareForReuse() {
        resetUIToDefaults()
    }

    
//    MARK: PRIVATE FUNCTIONS
    
    private func updateMarksColor() {
        switch prominence {
        case .normal:
            self.label.alpha = 1.0
            self.marksDisplayView.alpha = 1.0
        case .dim:
            self.label.alpha = 0.6
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
        
        if #available(iOS 13.0, *) {
            label.textColor = UIColor.label
        } else {
            label.textColor = UIColor.black
        }
    }
    
    private func resetUIToDefaults() {
        prominence = .normal
        isEmphasized = false
        isToday = false
        marks = []
        setNeedsDisplay()
    }

}
