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

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {
    static let SHIFTS_COUNT = 10
    
    @IBOutlet var tableView: UITableView?
    let userDefaults:UserDefaults = UserDefaults(suiteName: "group.org.boborbt.tshifts")!
    var shiftsDescriptions:[NSAttributedString] = [NSAttributedString](repeating: NSAttributedString(string:""), count: SHIFTS_COUNT)
    var calendarUpdater: CalendarShiftUpdater!
    var shiftStorage: CalendarShiftStorage!
    var options: Options!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #warning("FIXME: user defaults should be using the app group... this may destroy user data the first time the change is done")
        options = Options()
        calendarUpdater = CalendarShiftUpdater(calendarName: options.calendar, calendarUpdateCallback: TodayViewController.onCalendarUpdate(calendar:))
        shiftStorage = CalendarShiftStorage(updater: calendarUpdater, templates: options.shiftTemplates)
        
        tableView?.dataSource = self
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: UserDefaults.didChangeNotification, object: userDefaults)
        
        let _ = self.updateData()
    }
    
    static func onCalendarUpdate(calendar:EKCalendar) {
        #warning("FIXME")
    }
    
    func attributedDescription(for string:String, atIndex index: Int) -> NSAttributedString {
        let bullet = "‣ "
        let description = string
        
        let text = NSMutableAttributedString(string: bullet + description)
        if index == 1 {
            text.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location:0, length:bullet.count))
        }
        
        return text
    }
    
    @objc func updateData() -> Bool {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        var updated = false
        
        for i in 0..<TodayViewController.SHIFTS_COUNT {
            let date = Date.dateFromToday(byAdding: i-1)
//            let newDescription = attributedDescription(for: "\(date)\t: \(description)", atIndex: i)
            let newDescription = NSAttributedString(string: shiftStorage.shifts(at: date).description )
            

            if shiftsDescriptions[i] != newDescription {
                shiftsDescriptions[i] = newDescription
                updated = true
            }
        }

        
//        for i in 0..<TodayViewController.SHIFTS_COUNT {
//            guard let date = userDefaults.string(forKey: "shifts.date.\(i)") else { continue }
//            guard let description = userDefaults.string(forKey: "shifts.description.\(i)")  else { continue }
//            let newDescription = attributedDescription(for: "\(date)\t: \(description)", atIndex: i)
//
//
//            if shiftsDescriptions[i] != newDescription {
//                shiftsDescriptions[i] = newDescription
//                updated = true
//            }
//        }
        
        return updated
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftsDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetTableViewCell") as! WidgetTableViewCell
        
        cell.label?.text = nil
        cell.label?.attributedText = shiftsDescriptions[indexPath[1]]
        
        return cell
    }
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        let updated = self.updateData()
        
        completionHandler(updated ? .newData : .noData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode  {
        case .compact:
            self.preferredContentSize = CGSize(width: maxSize.width, height: min(maxSize.height, 90))
        case .expanded:
            self.preferredContentSize = CGSize(width: maxSize.width, height: 225)
        }
    }
}
