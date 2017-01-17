//
//  ShiftTableViewDelegate.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 16/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class ShiftTableViewDelegate : NSObject, UITableViewDelegate {
    var selectionCallback : ((Int) -> ())?
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectionCallback != nil {
            selectionCallback!(indexPath.row)
        }
    }
}
