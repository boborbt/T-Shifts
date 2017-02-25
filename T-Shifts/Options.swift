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
    
    lazy var shiftTemplates: ShiftTemplates = self.optionsToTemplates()
    
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
    
    func sync() {
        options.setValue( calendar, forKey: "Calendar")
        
        var templates: [[String:Any]] = []
        
        for template in shiftTemplates.templates {
            var dict: [String:Any] = [:]
            dict["description"] = template.shift.description
            dict["shortcut"] = template.shift.shortcut
            dict["position"] = template.position

            let color = template.color.cgColor.components!
            var colorDict = [String:Float]()
            colorDict["red"] = Float(color[0]) * 255.0
            colorDict["green"] = Float(color[1]) * 255.0
            colorDict["blue"] = Float(color[2]) * 255.0
            
            dict["color"] = colorDict
            
            templates.append(dict)
        }
        
        options.setValue( templates, forKey: "ShiftTemplates")
    }
    
    private func optionsToTemplates() -> ShiftTemplates {
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
        
        let result = ShiftTemplates()
        result.templates = resultArray
        
        return result
    }
}
