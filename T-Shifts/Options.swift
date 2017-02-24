//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit
import os.log

class Options {
    var options = UserDefaults.standard
    
    init() {
        let defaults = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Options", ofType: "plist")!)!
        options.register(defaults: defaults as! [String:Any])
    }
    
    lazy var shiftTemplates: ShiftTemplates = { () -> ShiftTemplates in
            var resultArray: [ShiftTemplate] = []
            let templates =  self.options.array(forKey:"ShiftTemplates") as! [[String:Any]]
            
            for template in templates {
                let position = template["position"] as! Int
                let description = template["description"] as! String
                let shortcut = template["shortcut"] as! String
                let color = template["color"] as! [String:Float]
                
                let shift = Shift(description: description, shortcut: shortcut)
                let shiftTemplate = ShiftTemplate(shift: shift, position: position, color: self.parse(color:color))
                resultArray.append(shiftTemplate)
            }
            
            var result = ShiftTemplates()
            result.templates = resultArray
        
            return result
    }()
    
    var calendar: String {
        get {
            return options.string(forKey: "Calendar")!
        }

        set(newVal) {
            options.setValue(newVal, forKey:"Calendar")
        }
    }
    
    func parse(color:[String:Float]) -> UIColor {
        let red = CGFloat(color["red"]!) / 255.0
        let green = CGFloat(color["green"]!) / 255.0
        let blue = CGFloat(color["blue"]!) / 255.0
        let alpha = CGFloat(1.0)
        
        os_log("color: %d red: %3.0f green: %3..0f blue: %3.0f alpha: %3.0f", color, red * 255.0, green * 255.0, blue * 255.0, alpha * 255.0)
        
        return UIColor(red: red , green: green, blue: blue, alpha: alpha)
    }
}
