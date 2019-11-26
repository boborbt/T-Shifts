//
//  BBShowEditTemplateButton.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/05/2019.
//  Copyright © 2019 Roberto Esposito. All rights reserved.
//

import UIKit

class ShowEditTemplateButton: UIButton {
    var field: UITextField!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(field: UITextField) {
        self.init(type:.custom)
        self.field = field
//        self.init(.zero)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
