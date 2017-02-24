//
//  MarkButton.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import EasyTipView

class MarkButton: UIButton {
    enum StateAlphaValues: CGFloat {
        case active = 1.0
        case inactive = 0.1
    }
    
    var color: CGColor! {
        didSet {
            let components = color.components!
            self.inactiveStateColor = UIColor(red: components[0], green: components[1], blue: components[2], alpha: StateAlphaValues.inactive.rawValue).cgColor
            
            self.layer.borderColor = color
            self.layer.backgroundColor = color
            
            self.setNeedsDisplay()
        }
    }
    
    var inactiveStateColor: CGColor!
    
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
                self.layer.backgroundColor = inactiveStateColor
            }
            
            self.setNeedsDisplay()
        }
        
        get {
            return self.layer.backgroundColor == color
        }
    }
    
    var tipView: EasyTipView!
    
    override func awakeFromNib() {
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
        
    }
    
    func setupForTemplate(template:ShiftTemplate) {
        self.color = template.color.cgColor
        self.setTitle(template.shift.shortcut, for: .normal)
        
        
        var tipViewPrefs = EasyTipView.Preferences()
        tipViewPrefs.drawing.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        tipViewPrefs.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        self.tipView = EasyTipView(text:template.shift.description, preferences: tipViewPrefs)
    }
    
    func setupTaps(controller:ViewController) {
        self.addTarget(controller, action: #selector(controller.addShift(_:)), for: .touchUpInside)
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showTip(_:)))
        
        longTapRecognizer.numberOfTapsRequired = 0
        longTapRecognizer.minimumPressDuration = 0.5
        
        self.addGestureRecognizer(longTapRecognizer)
    }
    
    func showTip(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            tipView.show(forView: sender.view!)
            return
        }
            
        if sender.state == .ended {
            tipView.dismiss()
        }
    }


}
