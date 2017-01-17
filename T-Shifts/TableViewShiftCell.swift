//
//  TableViewCell.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 13/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class TableViewShiftCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
