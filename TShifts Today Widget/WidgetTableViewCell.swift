//
//  File.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 13/11/2018.
//  Copyright © 2018 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit

class WidgetTableViewCell:UITableViewCell {
    @IBOutlet var label: UILabel?
    
    override func awakeFromNib() {
        label?.text = "Test"
    }
}
