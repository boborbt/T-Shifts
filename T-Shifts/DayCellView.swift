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
    
    var showEmphasis: Bool = false
    var showTodayMark: Bool = false
    
    var isToday: Bool {
        set(newVal) {
            showTodayMark = newVal
            setNeedsDisplay()
        }
        
        get {
            return showTodayMark
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
//            UIView.animate(withDuration: 0.5, animations: {
//                self.selectionEmphasis.alpha = newVal ? 1.0 : 0.0
//            })
        }
    }
    
    var isInCurrentMonth: Bool {
        get {
            return label.textColor.isEqual(Colors.black)
        }
        
        set(newVal) {
            if newVal {
                label.textColor = Colors.black
            } else {
                label.textColor = Colors.gray
            }
        }
    }
    
    @IBOutlet weak var mark1: ShiftTypeMarkView!
    @IBOutlet weak var mark2: ShiftTypeMarkView!
    @IBOutlet weak var mark3: ShiftTypeMarkView!
    @IBOutlet weak var mark4: ShiftTypeMarkView!

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if showTodayMark {
            drawTodayMark(rect)
        }
    }
    
    func drawTodayMark(_ rect: CGRect) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.midX,y: rect.midY), radius: rect.width / 2.5, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        
        UIColor.red.setStroke()
        circlePath.stroke()
    }
}
