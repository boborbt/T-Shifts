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
    var markNames: [ShiftTypeMarkView:String]!
    
    var marks: [String] {
        get {
            var result: [String] = []
            for (mark,shortcut) in markNames {
                if mark.alpha > 0.0 {
                    result.append(shortcut)
                }
            }
            return result
        }
        
        set(newMarks) {
            for (mark, shortcut) in markNames {
                let display = newMarks.index(where: { str in return shortcut == str }) != nil
                mark.alpha = display ? 1.0 : 0.0
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
        markNames = [mark1:"M", mark2:"P", mark3:"N", mark4:"R"]

        for (mark,_) in markNames {
            mark.layer.cornerRadius = 5
        }
    }
}
