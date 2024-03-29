//
//  Options.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import os.log

public class Options {

    var options = UserDefaults(suiteName: "group.org.boborbt.tshifts-v2")!
    let logger = OSLog(subsystem:"org.boborbt.tshifts", category:"options")
    
    public init() {
        migrateOptions()
        options.register(defaults: readDefaults())
    }
    
    public lazy var shiftTemplates: ShiftTemplates = self.optionsToTemplates()
    
    
    // Returns the default values for the option dictionary
    //
    // If this function is called from the main app, it has access to the main bundle. In this
    // case it reads the defaults from the main bundle, write it onto the shared container
    // "group.org.boborbt.tshifts.option-templates" and returns the read content.
    //
    // If this function is called from an extension, it simply queries the shared container to
    // the the required content.
    func readDefaults() -> [String:Any] {
        let defaults = UserDefaults(suiteName: "group.org.boborbt.tshifts.option-templates")!
        
        if let plistPath = Bundle.app.path(forResource: "Options", ofType: "plist") {
            os_log(.debug, log:logger, "Template Defaults: writing defaults read from main bundle")
            let dictionary = NSDictionary(contentsOfFile: plistPath)!
            defaults.set(dictionary, forKey:"defaults-dictionary")
            defaults.synchronize()
        } else {
            fatalError("Cannot access the app bundle")
        }
    
        return defaults.dictionary(forKey:"defaults-dictionary")!
    }
    
    func migrateOptions() {
        let version = options.integer(forKey: "version")
        if version >= 2 {
            os_log(.debug, log:logger, "Options Migration: Skipping (already on version 2)")
            return
        }
        
        os_log(.info, log:logger, "Options Migration: migrating from version %d to version 2", version)
        
        let old_defaults = UserDefaults.standard
        for key in old_defaults.dictionaryRepresentation().keys {
            let object = old_defaults.object(forKey: key)
            options.set(object, forKey: key)
        }

        options.set(2, forKey: "version")
    }
    
    public var calendar: String {
        get {
            return options.string(forKey: "Calendar")!
        }

        set(newVal) {
            options.setValue(newVal, forKey:"Calendar")
        }
    }
    
    
    public func parse(color:[String:Float]) -> UIColor {
        let red = CGFloat(color["red"]!) / 255.0
        let green = CGFloat(color["green"]!) / 255.0
        let blue = CGFloat(color["blue"]!) / 255.0
        let alpha = CGFloat(1.0)
                
        return UIColor(red: red , green: green, blue: blue, alpha: alpha)
    }
    
   public func sync() {
        options.setValue(calendar, forKey: "Calendar")
        
        var templates: [[String:Any]] = []
        
        for template in shiftTemplates.templates() {
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
            
            var startTime = [String:Int]()
            startTime["hour"] = template.shift.startTime.hour
            startTime["minute"] = template.shift.startTime.minute
            
            var endTime = [String:Int]()
            endTime["hour"] = template.shift.endTime.hour
            endTime["minute"] = template.shift.endTime.minute
            
            dict["isAllDay"] = template.shift.isAllDay
            dict["startTime"] = startTime
            dict["endTime"] = endTime
            
            dict["alertActive"] = template.shift.alert.active
            dict["alertMinutes"] = template.shift.alert.minutes
            
            templates.append(dict)
        }
        
        options.setValue( templates, forKey: "ShiftTemplates")
        os_log(.info, log:logger, "Options synced")
    }
    
    private func optionsToTemplates() -> ShiftTemplates {
        var resultArray: [ShiftTemplate] = []
        let templates =  self.options.array(forKey:"ShiftTemplates") as! [[String:Any]]
        
        for template in templates {
            let position = template["position"] as! Int
            let description = template["description"] as! String
            let shortcut = template["shortcut"] as! String
            let color = template["color"] as! [String:Float]
            let st = (template["startTime"] as? [String:Int]) ?? [:]
            let et = (template["endTime"] as? [String:Int]) ?? [:]
            let alertActive = (template["alertActive"] as? Bool) ?? false
            let alertMinutes = (template["alertMinutes"] as? Int) ?? 60
            
            
            let shift = Shift(description: description,
                              shortcut: shortcut,
                              isAllDay: template["isAllDay"] as? Bool ?? true,
                              startTime:(st["hour"] ?? 8, st["minute"] ?? 0),
                              endTime:(et["hour"] ?? 16, et["minute"] ?? 0),
                              alert: (active:alertActive, minutes:alertMinutes))
            
            let shiftTemplate = ShiftTemplate(shift: shift, position: position, color: self.parse(color:color))
            resultArray.append(shiftTemplate)
        }
        
        let result = ShiftTemplates()
        result.storage = resultArray
        
        return result
    }
}
