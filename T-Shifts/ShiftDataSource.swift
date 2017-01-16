//
//  ShiftDataSource.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 13/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class ShiftDataSource : NSObject, UITableViewDataSource {
    let shiftStorage: ShiftStorage
    let dateFormatter: DateFormatter = DateFormatter()
    
    init(storage: ShiftStorage) {
        self.shiftStorage = storage
        self.dateFormatter.dateStyle = .medium
        self.dateFormatter.timeStyle = .none
        self.dateFormatter.locale =  Locale.current
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ViewController.SHIFT_VIEW_CELL_ID) as! TableViewShiftCell
        
        let shift = shiftStorage.shifts[indexPath.row]
        
        cell.descriptionLabel.text = shift.value
        cell.dateLabel.text = dateFormatter.string(from: shift.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("numberOfRowsInSection: %d", shiftStorage.shifts.count)
        return shiftStorage.shifts.count
    }
}
