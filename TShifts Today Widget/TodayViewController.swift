//
//  TodayViewController.swift
//  TShifts Today Widget
//
//  Created by Roberto Esposito on 13/11/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import UIKit
import NotificationCenter
import TShiftsFramework
import EventKit
import os.log


class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {
    static let SHIFTS_COUNT = 10
    
    @IBOutlet var tableView: UITableView?
    let userDefaults:UserDefaults = UserDefaults(suiteName: "group.org.boborbt.tshifts")!
    var shiftsDescriptions:[(Date,[Shift])] = []
    var calendarUpdater: CalendarShiftUpdater!
    var shiftStorage: CalendarShiftStorage!
    var options: Options!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options = Options()
        calendarUpdater = CalendarShiftUpdater(calendarName: options.calendar, calendarUpdateCallback: self.onCalendarUpdate(calendar:))
        shiftStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
        
        tableView?.dataSource = self
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: UserDefaults.didChangeNotification, object: userDefaults)
        
        let _ = self.updateData()
    }
    
    @objc func onCalendarUpdate(calendar:EKCalendar) {
        guard shiftStorage != nil else { return }
        let _ = self.updateData()
    }

    
    @objc func updateData() -> Bool {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        shiftsDescriptions = []
        
        for i in 0..<TodayViewController.SHIFTS_COUNT {
            let date = Date.dateFromToday(byAdding: i-1)
            let shifts = shiftStorage.shifts(at: date)
            shiftsDescriptions.append((date, shifts))
        }
        
        return true
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftsDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetTableViewCell") as! WidgetTableViewCell
        let (date, shifts) = shiftsDescriptions[indexPath[1]]
        
        os_log(.debug, "cell day is being set to: %s", date.description)
        cell.set(day: date, shifts: shifts)
        
        return cell
    }
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let updated = self.updateData()
        
        completionHandler(updated ? .newData : .noData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        let totalHeight = tableView!.contentSize.height
        
        switch activeDisplayMode  {
        case .compact:
            self.preferredContentSize = CGSize(width: maxSize.width, height: maxSize.height )
        case .expanded:
            self.preferredContentSize = CGSize(width: maxSize.width, height: totalHeight + 10)
        }
    }
}
