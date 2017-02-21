//
//  MarksDisplayView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class MarksDisplayView: UIView {
    static var templates: ShiftTemplates!
    struct Metrics {
        static let inset = CGFloat(3)
        static let radiusRatio = CGFloat(8)
    }
    
    
    var marks:[ShiftTemplate] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func drawLargeMarks(_ rect: CGRect) {
        let numMarks = 5
        
        let markHeight = rect.height / CGFloat(numMarks) - 3
        let markWidth = rect.width
        let markX = CGFloat(0.0)
        
        for mark in marks {
            let markY = CGFloat(mark.position) * (markHeight + Metrics.inset)
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
        
        for mark in marks {
            let pos = mark.position
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
        
        if MarksDisplayView.templates.count <= 5 {
            drawLargeMarks(rect)
        } else {
            drawSmallMarks(rect)
        }
    }

}
