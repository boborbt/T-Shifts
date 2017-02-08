//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

class Options {
    var options = OptionsFileManager.shared.read()
        
    
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
            OptionsFileManager.shared.write(options:options)
        }
    }
        
}
