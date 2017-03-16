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
        showOptions()
    }
    
    func appChangedStateToNeedsCalendarAccess() {        
        calendarUpdater.requestAccess( completion: { granted, _ in
            if !granted {
                self.showCalendarAccessNotGrantedErrorView()
                self.state = .needsCalendarAccess
            } else {
                self.reloadOptions()
                self.state = .ready
            }
        })

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
    
    func showOptions() {
        os_log("showOptions")
        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        guard let storyboard = navigationController.storyboard else { return }
        
        let optionsViewController = storyboard.instantiateViewController(withIdentifier: "optionsViewController")
        

        navigationController.pushViewController(optionsViewController, animated: true)
    }
    
    func showCalendarAccessNotGrantedErrorView() {
        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        guard let storyboard = navigationController.storyboard else { return }
        
        let calendarAccessNotGrantedController = storyboard.instantiateViewController(withIdentifier: "calendarAccessNotGranted")
        
        
        navigationController.pushViewController(calendarAccessNotGrantedController, animated: true)
    }
}
