//
//  AppDelegate.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import os.log
import CoreSpotlight
import TShiftsFramework
import EventKit


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
            case (.starting, .starting):
                checkState()
            case (.ready, .ready):
                os_log("App ready")
            case (.needsCalendarAccess, .needsCalendarAccess):
                self.showCalendarAccessNotGrantedErrorView()
            case let matchedState where matchedState.0 == matchedState.1:
                break
            case (_, .needsConfiguration):
                appChangedStateToNeedsConfiguration()
            case (_,.needsCalendarAccess):
                appChangedStateToNeedsCalendarAccess()
            default:
                checkState()
            }
            
        }
    }

    var window: UIWindow?
    var shiftStorage: ShiftStorage!
    var calendarUpdater: CalendarShiftUpdater!
    var options = Options()
    
    weak var mainController: MainViewController! {
        didSet {
            state = .starting
        }
    }
    
    weak var optionsController: OptionsViewController!
    
    func reloadOptions() {
        options.shiftTemplates.recomputeShortcuts()
        options.sync()
        
        calendarUpdater.switchToCalendar(named: options.calendar)
        mainController.calendarView.reloadData()
        mainController.dayInfoView.refresh()
    }
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        calendarUpdater = CalendarShiftUpdater(calendarName: options.calendar, calendarUpdateCallback: AppDelegate.onCalendarUpdate(calendar:))
        shiftStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
        
        return true
    }
    
    static func onCalendarUpdate(calendar:EKCalendar) -> () {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.options.calendar = calendar.title
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        do {
            let changedDates = try shiftStorage.commit()
            mainController.indexer.reindexShifts(for: changedDates)
        } catch let error {
            os_log(.error, "Error: %@", [error])
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        do {
            let changedDates = try shiftStorage.commit()
            mainController.indexer.reindexShifts(for: changedDates)
        } catch let error {
            os_log(.error, "Error: %@", [error])
        }
    }
    

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard let identifier = userActivity.userInfo![CSSearchableItemActivityIdentifier] as? String
        else {
            mainController.indexer.resetIndex()
            return false
        }
        
        if let date = shiftStorage.date(forUniqueIdentifier: identifier) {
            mainController.select(date: date)
        } else {
            mainController.indexer.resetIndex()
        }
        return true
    }

}

