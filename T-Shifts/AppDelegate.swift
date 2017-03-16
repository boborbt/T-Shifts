//
//  AppDelegate.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    enum State {
        case starting
        case needsConfiguration
        case needsCalendarAccess
        case ready
    }
    
    var state: State = .starting {
        didSet {
            switch (oldValue,state) {
            case (_, .needsConfiguration):
                appChangedStateToNeedsConfiguration()
            case (_,.needsCalendarAccess):
                appChangedStateToNeedsCalendarAccess()
            case (_,.ready):
                appChangedStateToReady()
            case (_,.starting):
                checkState()
            }
            
        }
    }

    var window: UIWindow?
    var shiftStorage: CalendarShiftStorage?
    var calendarUpdater: CalendarShiftUpdater!
    var options = Options()
    
    weak var mainController: ViewController! {
        didSet {
            state = .starting
        }
    }
    
    weak var optionsController: OptionsViewController!
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        calendarUpdater = CalendarShiftUpdater(calendarName:options.calendar)
        shiftStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
        
        return true
    }
    
    
    func reloadOptions() {
        options.shiftTemplates.recomputeShortcuts()
        options.sync()
        
        calendarUpdater.switchToCalendar(named: options.calendar)
        mainController.calendarView.reloadData()
        mainController.dayInfoView.refresh()
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

