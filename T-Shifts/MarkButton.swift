//
//  MarkButton.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class MarkButton: UIButton {
    override func awakeFromNib() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        guard let template = delegate.shiftTemplates.template(at: self.tag) else { return }
        
        self.layer.borderColor = template.color.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5
        
        self.setTitle(template.shift.shortcut, for: .normal)
    }
    
    func setupTaps(controller:ViewController) {
//        let tapGesture = UITapGestureRecognizer(target: controller, action: #selector(controller.addShift(_:)))  //Tap function will call when user tap on button
//        //        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(ViewController)) //Long function will call when user long press on button.
//        
//        tapGesture.numberOfTapsRequired = 1
//        
//        
//        self.addGestureRecognizer(tapGesture)
        
        self.addTarget(controller, action: #selector(controller.addShift(_:)), for: .touchUpInside)
        //        self.addGestureRecognizer(longGesture)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
