//
//  DayInfoViewSecurePanelExtension.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 11/09/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import UIKit

extension DayInfoView {
    var TAP_OPEN_OFFSET:CGFloat {
        get {
            return 20.0
        }
    }
    
    
    func setupSecurePanel() {
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panelPan(recognizer:)))
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(panelTap(recognizer:)))
        securePanelView.addGestureRecognizer(panRecognizer)
        securePanelView.addGestureRecognizer(tapRecognizer)
    }

    @objc func panelPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: securePanelView)
        let direction:CGFloat = self.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1.0 : 1.0
        
        let left_bound = -Aspect.inset
        let right_bound = markButtonsArrayView.frame.width - Aspect.inset
        
        securePanelViewLeadingConstraint.constant += translation.x * direction
        if securePanelViewLeadingConstraint.constant < left_bound {
            securePanelViewLeadingConstraint.constant = left_bound
        }
        
        if securePanelViewLeadingConstraint.constant > right_bound {
            securePanelViewLeadingConstraint.constant = right_bound
        }
        
        
        if recognizer.state == .ended {
            feedbackGenerator.prepare()
            
            // we add velocity.x to the current position to simulate
            // a bit of inertia
            let x = CGFloat(securePanelViewLeadingConstraint.constant) + direction * recognizer.velocity(in: securePanelView).x / 10
            
            if abs(x - left_bound) < abs(x - right_bound) {
                securePanelViewLeadingConstraint.constant = left_bound
            } else {
                securePanelViewLeadingConstraint.constant = right_bound
            }
            
            UIView.animate(withDuration: 0.2, animations: { self.layoutIfNeeded() }, completion: {
                _ in    self.feedbackGenerator.impactOccurred()
            })
            
        } else {
            recognizer.setTranslation(CGPoint.zero, in: securePanelView)
            self.layoutIfNeeded()
        }
    }
    
    @objc func panelTap(recognizer: UITapGestureRecognizer) {
        let left_bound = -Aspect.inset
        feedbackGenerator.prepare()
        
        let smallBounce = {
            self.feedbackGenerator.prepare()
            self.securePanelViewLeadingConstraint.constant = left_bound + self.TAP_OPEN_OFFSET/3
            UIView.animate(withDuration: 0.05, animations: { self.layoutIfNeeded() } , completion: { _ in
                self.securePanelViewLeadingConstraint.constant = left_bound
                UIView.animate(withDuration: 0.05, animations: { self.layoutIfNeeded() }, completion: { _ in
                    self.feedbackGenerator.impactOccurred()
                })
            })
        }
        
        let doubleBounce = {
            self.securePanelViewLeadingConstraint.constant = left_bound + self.TAP_OPEN_OFFSET
            UIView.animate(withDuration:0.1, animations: { self.layoutIfNeeded() }, completion: { _ in
                self.securePanelViewLeadingConstraint.constant = left_bound;
                UIView.animate(withDuration:0.1, animations: { self.layoutIfNeeded()}, completion: { _ in
                    self.feedbackGenerator.impactOccurred()
                    smallBounce()
                })
            })
        }
        
        if(securePanelViewLeadingConstraint.constant == left_bound) {
            doubleBounce()
        }
    }
    
}
