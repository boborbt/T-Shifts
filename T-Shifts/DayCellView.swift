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
    
    var isToday: Bool = false
    
    @IBOutlet weak var mark1: ShiftTypeMarkView!
    @IBOutlet weak var mark2: ShiftTypeMarkView!
    @IBOutlet weak var mark3: ShiftTypeMarkView!
    @IBOutlet weak var mark4: ShiftTypeMarkView!

    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if isToday {
            drawTodayMark(rect)
        }
    }
    
    func drawTodayMark(_ rect: CGRect) {
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: rect.midX,y: rect.midY), radius: rect.width / 2.5, startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        
        UIColor.red.setStroke()
        circlePath.stroke()
    }
}
