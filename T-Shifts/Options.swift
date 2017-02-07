//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

class Options {
    var options = NSDictionary(contentsOfFile: Bundle.main.path(forResource:"Options", ofType:"plist")!) as! [String:Any]
    
    var shiftNames: [String:String] {
        get {
            return options["ShiftNames"] as! [String:String]
        }
    }
    
    var shiftNamesOrder: [String] {
        get {
            return options["ShiftNamesOrder"] as! [String]
        }
    }
    
    var calendar: String {
        get {
            return options["Calendar"] as! String
        }

        set(newVal) {
            guard options["Calendar"] as! String != newVal else { return }
            
            options["Calendar"] = newVal
            sync()
        }
    }
    
        
    private func sync() {
        let dict = options as NSDictionary
        dict.write(toFile: Bundle.main.path(forResource:"Options", ofType:"plist")!, atomically: true)
    }
}
