//
//  TodayViewController.swift
//  TShifts Today Widget
//
//  Created by Roberto Esposito on 13/11/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDataSource {

    
    @IBOutlet var tableView: UITableView?
    let userDefaults:UserDefaults = UserDefaults(suiteName: "group.tshifts.boborbt.org")!
    var shiftsDescriptions:[String] = []
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.dataSource = self
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: UserDefaults.didChangeNotification, object: userDefaults)
        
        userDefaults.synchronize()
        self.updateData()
    }
    
    @objc func updateData() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        shiftsDescriptions = []
        for i in 0...10 {
            guard let date = userDefaults.string(forKey: "shifts.date.\(i)") else { continue }
            guard let description = userDefaults.string(forKey: "shifts.description.\(i)")  else { continue }
            shiftsDescriptions.append("\(date): \(description)")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shiftsDescriptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WidgetTableViewCell") as! WidgetTableViewCell
        let bullet = "‣ "
        let description = shiftsDescriptions[indexPath[1]]
        
        let text = NSMutableAttributedString(string: bullet + description)
        if indexPath[1] == 1 {
            text.addAttribute(.foregroundColor, value: UIColor.red, range: NSRange(location:0, length:bullet.count))
        }
        
        cell.label?.text = nil
        cell.label?.attributedText = text
        
        return cell
    }
    
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
