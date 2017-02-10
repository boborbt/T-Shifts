//
//  ShiftTypeMarkView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 10/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class ShiftTypeMarkView: UIView {
    var color: UIColor {
        get {
            return self.backgroundColor!
        }
    
        set(newColor) {
            self.backgroundColor = newColor
        }
    }
}
