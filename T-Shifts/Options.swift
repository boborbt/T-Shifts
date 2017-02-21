//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class Options {
    var options = UserDefaults.standard
    
    init() {
        let defaults = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Options", ofType: "plist")!)!
        options.register(defaults: defaults as! [String:Any])
    }
    
    var shiftTemplates: [ShiftTemplate] {
        get {
            var result: [ShiftTemplate] = []
            let templates =  options.array(forKey:"ShiftTemplates") as! [[String:Any]]
            
            for template in templates {
                let position = template["position"] as! Int
                let description = template["description"] as! String
                let shortcut = template["shortcut"] as! String
                let color = template["color"] as! Int
                
                let shift = Shift(description: description, shortcut: shortcut)
                let shiftTemplate = ShiftTemplate(shift: shift, position: position, color: parse(color:color))
                result.append(shiftTemplate)
            }
            
            return result
        }
    }
    
    func parse(color:Int) -> UIColor {
        let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat((color & 0x0000FF)) / 255.0
        
        return UIColor(red: red , green: green, blue: blue, alpha: 1.0)
        
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
