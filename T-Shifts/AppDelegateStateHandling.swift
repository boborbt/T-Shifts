//
//  AppDelegateStateHandling.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 16/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit
import os.log

extension AppDelegate {
    func appChangedStateToNeedsConfiguration() {
        let preferenceButton = mainController.preferenceButton!
        UIApplication.shared.sendAction(preferenceButton.action!, to: preferenceButton.target, from: nil, for: nil)
        // the option controller should call checkState once the user dismiss it
    }
    
    func appChangedStateToNeedsCalendarAccess() {
        calendarUpdater.requestAccess( completion: { granted, error in
            if !granted || error != nil {
                if !granted {
                    os_log("Not granted")
                    self.state = .needsConfiguration
                } else {
                    os_log("Error")
                }
                return
            }
            
            self.checkState()
        })

    }
    
    func appChangedStateToReady() {
        // FIXME: show main windows
    }
    
    func checkState() {
        if !CalendarShiftUpdater.isAccessGranted() {
            state = .needsCalendarAccess
            return
        }
        
        if options.calendar == "None" || calendarUpdater.targetCalendar == nil {
            state = .needsConfiguration
            return
        }
        
        // FIXME: handle .starting 
        
        state = .ready
    }
}
