//
//  MarkButton.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class MarkButton: UIButton {
    var color: CGColor! {
        didSet {
            self.layer.borderColor = color
            self.setNeedsDisplay()
        }
    }
    
    var isVisible: Bool {
        get {
            return self.alpha != 0
        }
        
        set(newVal) {
            self.alpha = newVal ? 1.0 : 0.0
        }
    }
    
    var isActive: Bool {
        set(newVal) {
            if newVal {
                self.layer.backgroundColor = color
            } else {
                self.layer.backgroundColor = UIColor.white.cgColor
            }
            
            self.setNeedsDisplay()
        }
        
        get {
            return self.layer.backgroundColor == UIColor.white.cgColor
        }
    }
    
    override func awakeFromNib() {
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
    }
    
    func setupForTemplate(template:ShiftTemplate) {
        self.color = template.color.cgColor
        self.setTitle(template.shift.shortcut, for: .normal)
    }
    
    func setupTaps(controller:ViewController) {
        self.addTarget(controller, action: #selector(controller.addShift(_:)), for: .touchUpInside)
    }
}
