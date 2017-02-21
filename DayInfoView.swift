//
//  DayInfoView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class DayInfoView: UIView {
    weak var controller:ViewController!

    func setupButtonTaps(controller:ViewController) {
        for markButton in markButtonViews(from:subviews, depth: 30) {
            markButton.setupTaps(controller: controller)
        }
    }
    
    func markButtonViews(from views:[UIView], depth: Int) -> [MarkButton] {
        guard !views.isEmpty && depth > 0 else { return [] }
        
        var result: [MarkButton] = []
        for view in views {
            if view is MarkButton {
                result.append(view as! MarkButton)
            } else {
                result.append(contentsOf: markButtonViews(from: view.subviews, depth: depth - 1))
            }
        }
        
        return result
    }
}
