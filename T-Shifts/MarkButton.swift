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
    
    weak var dayInfoDelegate: DayInfoViewDelegate!
    
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
                self.setTitleColor(UIColor.white, for: .normal)
            } else {
                self.layer.backgroundColor = inactiveStateColor
                self.setTitleColor(UIColor.black, for: .normal)
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
        tipViewPrefs.drawing.backgroundColor = UIColor.blue
        tipViewPrefs.drawing.arrowPosition = EasyTipView.ArrowPosition.bottom
        self.tipView = EasyTipView(text:template.shift.description, preferences: tipViewPrefs)
    }
    
    func setupTaps(dayInfoDelegate:DayInfoViewDelegate) {
        self.dayInfoDelegate = dayInfoDelegate
        self.addTarget(self, action: #selector(self.tapEvent), for: .touchUpInside)
        
        let longTapRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.showTip(_:)))
        
        longTapRecognizer.numberOfTapsRequired = 0
        longTapRecognizer.minimumPressDuration = 0.5
        
        self.addGestureRecognizer(longTapRecognizer)
    }
    
    func tapEvent() {
        dayInfoDelegate.dayInfoTapOn(shiftButton: self)
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
