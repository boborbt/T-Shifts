//
//  BBShowEditTemplateButton.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/05/2019.
//  Copyright © 2019 Roberto Esposito. All rights reserved.
//

import UIKit

class ShowEditTemplateButton: UIButton {
    var info: String
    
    required init?(coder aDecoder: NSCoder) {
        info = ""
        super.init(coder:aDecoder)
    }
    
    override init(frame: CGRect) {
        info = ""
        super.init(frame: frame)
    }
    
    convenience init(info: String) {
        self.init(type:.custom)
        self.info = info
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
