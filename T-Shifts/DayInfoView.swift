//
//  DayInfoView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class DayInfoView: UIView {
    weak var controller:ViewController!
    weak var dayCell: DayCellView!
    weak var markButtonsArray: MarkButtonsArrayView!

    

    func setupButtons(controller:ViewController, templates: ShiftTemplates) {
        for markButton in markButtonsArray.markButtonsArray {
            markButton.isVisible = false
            let template = templates.template(at: markButton.tag)!
            
            if template.shift.description != "" {
                markButton.isVisible = true
                markButton.setupTaps(controller: controller)
                markButton.setupForTemplate(template: template)
            }
        }
    }
    
    func activateMarkButtons(templates:[ShiftTemplate]) {
        for markButton in markButtonsArray.markButtonsArray {
            markButton.isActive = false
        }
        
        for template in templates {
            markButtonsArray.markButtonsArray[template.position].isActive = true
        }
    }
    
    func refreshButtons(controller: ViewController, templates:ShiftTemplates) {
        setupButtons(controller: controller, templates: templates)
    }
    

}
