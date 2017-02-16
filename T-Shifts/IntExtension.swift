//
//  IntExtension.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 16/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

extension Int {
    func days() -> Double {
        return 60.0 * 60.0 * 24.0 * Double(self)
    }
    
    func weeks() -> Double {
        return Double(self) * 7.days()
    }
}
