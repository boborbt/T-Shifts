//
//  OptionsFileManager.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 08/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation

class OptionsFileManager {
    static var shared = OptionsFileManager("Options")
    
    var fileName: String
    var userFileName: String
    
    var userFilePath: String {
        get {
            let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            return appSupportPath.appendingPathComponent(userFileName).absoluteString
        }
    }
    
    var bundleFilePath: String {
        get {
            let bundlePath = Bundle.main.path(forResource: fileName, ofType: "plist")
            return bundlePath!
        }
    }
    
    var optionsFilePath: String {
        get {
            if FileManager.default.fileExists(atPath: userFilePath) {
                return userFilePath
            } else {
                return bundleFilePath
            }
        }
    }
    
    init(_ fn:String) {
        fileName = fn
        userFileName = "User\(fn)"
    }
    
    
    func read() -> [String:Any] {
        let dictionary = NSDictionary(contentsOfFile: optionsFilePath)
        return dictionary as! [String:Any]
    }
    
    func write(options dictionary: [String:Any]) {
        let dict = dictionary as NSDictionary
        
        if !dict.write(toFile: userFilePath, atomically: true) {
            NSLog("Failed to sync options to disk at path \(userFilePath)")
        } else {
            NSLog("Sync succesful")
        }
    }
    
    
}
