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
                DispatchQueue.main.async {
                    self.state = .needsCalendarAccess
                }
            } else {
                DispatchQueue.main.async {
                    self.reloadOptions()
                    self.state = .needsConfiguration
                }
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
        
        
        state = .ready
    }
    
    func showOptions() {
        os_log("showOptions")
        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        
        let optionsViewController = OptionsViewController()
        
        navigationController.pushViewController(optionsViewController, animated: true)
    }
    
    func showCalendarAccessNotGrantedErrorView() {
        guard let navigationController = self.window?.rootViewController as? UINavigationController else { return }
        guard let storyboard = navigationController.storyboard else { return }
        
        let calendarAccessNotGrantedController = storyboard.instantiateViewController(withIdentifier: "calendarAccessNotGranted")
        
        navigationController.present(calendarAccessNotGrantedController, animated: true, completion: {
            self.checkState()
        })
    }
}
