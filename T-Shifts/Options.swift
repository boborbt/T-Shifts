//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

class Options {
    var options = UserDefaults.standard
    
    init() {
        let defaults = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Options", ofType: "plist")!)!
        options.register(defaults: defaults as! [String:Any])
    }
        
    
    var shiftNames: [String:String] {
        get {
            return options.dictionary(forKey: "ShiftNames") as! [String:String]
        }
    }
    
    var shiftNamesOrder: [String] {
        get {
            return options.array(forKey: "ShiftNamesOrder") as! [String]
        }
    }
    
    var calendar: String {
        get {
            return options.string(forKey: "Calendar")!
        }

        set(newVal) {
            options.setValue(newVal, forKey:"Calendar")
        }
    }
        
}
