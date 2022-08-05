//
//  MarksDisplayView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import TShiftsFramework
import OSLog

class MarksDisplayView: UIView {
    struct Metrics {
        static let inset = CGFloat(3)
        static let radiusRatio = CGFloat(8)
    }
    
    
    var marks:[TShiftsFramework.ShiftTemplate] = [] {
        didSet {
            marks.sort { t1,t2 in
                return t1.position < t2.position
            }
            setNeedsDisplay()
        }
    }
    
    func drawMarksAndShortcut(_ rect: CGRect) {
        let numMarks = 3
        
        let markHeight = rect.height / CGFloat(numMarks) - 3
        let markWidth = rect.width
        let markX = CGFloat(0.0)
        
        for (index, mark) in marks.enumerated() {
            let markY = CGFloat(index) * (markHeight + Metrics.inset)
            let rect = CGRect(x: markX, y: markY, width: markWidth, height: markHeight)
            let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: markHeight / Metrics.radiusRatio)

            mark.color.setFill()
            roundedRect.fill()
            
            let strSize = mark.shift.shortcut.size()
            let strX = markX + markWidth/2 - strSize.width/2
            let strY = markY + markHeight/2 - strSize.height/2
            let sc = mark.shift.shortcut
            sc.draw(at: CGPoint(x: strX, y: strY), withAttributes: [.foregroundColor : UIColor.label] )
            os_log("index: \(index) dshortcut: \(mark.shift.shortcut) y:\(markY/2 + CGFloat(index) * markHeight)")
        }
    }
    
    func drawLargeMarks(_ rect: CGRect) {
        let numMarks = 5
        
        let markHeight = rect.height / CGFloat(numMarks) - 3
        let markWidth = rect.width
        let markX = CGFloat(0.0)
        
        for (index, mark) in marks.enumerated() {
            let markY = CGFloat(index) * (markHeight + Metrics.inset)
            let rect = CGRect(x: markX, y: markY, width: markWidth, height: markHeight)
            let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: markHeight / Metrics.radiusRatio)
            
            mark.color.setFill()
            roundedRect.fill()
        }
    }
    
    func drawSmallMarks(_ rect: CGRect) {
        let numRows = 3
        let numCols = 3
        let markHeight = rect.height / CGFloat(numRows) - Metrics.inset
        let markWidth = rect.width / CGFloat(numCols) - Metrics.inset
        
        for (index,mark) in marks.enumerated() {
            let pos = index
            let markX = CGFloat(pos % numCols) * (markWidth + Metrics.inset)
            let markY = CGFloat(pos / numCols) * (markHeight + Metrics.inset)
            let rect = CGRect(x: markX, y:markY, width: markWidth, height: markHeight)
            let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: markHeight / Metrics.radiusRatio)
            
            mark.color.setFill()
            roundedRect.fill()
        }
        
    }

    override func draw(_ rect: CGRect) {
        guard marks.count > 0 else { return }
        
        switch marks.count {
        case 0...3:
            drawMarksAndShortcut(rect)
        case 4...5:
            drawLargeMarks(rect)
        default:
            drawSmallMarks(rect)
        }
    }

}
