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
    
    @IBOutlet weak var mark1: ShiftTypeMarkView!
    @IBOutlet weak var mark2: ShiftTypeMarkView!
    @IBOutlet weak var mark3: ShiftTypeMarkView!
    @IBOutlet weak var mark4: ShiftTypeMarkView!

    
    var isToday: Bool = false
    var isInCurrentMonth: Bool = false
    
    var showEmphasis: Bool = false
    var showTodayMark: Bool = false
    var markViews: [ShiftTypeMarkView]!
    var marks: [ShiftTemplate] = [] {
        didSet {
            for mark in markViews {
                mark.alpha = 0.0
            }
            
            for template in marks {
                let markView = markViews[template.position]
                markView.alpha = 1.0
                markView.color = template.color
            }
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
    
    func updateAspect() {
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
    
    override func awakeFromNib() {
        markViews = [mark1, mark2, mark3, mark4]

        for mark in markViews {
            mark.layer.cornerRadius = 5
            mark.alpha = 0.0
        }
    }
    
    func copyAttributes(from dayCell:DayCellView) {
        label.text = dayCell.label.text
        isToday = dayCell.isToday
        isInCurrentMonth = dayCell.isInCurrentMonth
        marks = dayCell.marks
        
        updateAspect()
    }
    
    func clearAttributes() {
        isToday = false
        label.text = ""
        marks = []
        updateAspect()
    }
}
