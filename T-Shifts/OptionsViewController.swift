//
//  PreferenceViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 23/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit
import Eureka


class OptionsViewController : FormViewController {
    weak var options: Options!
    weak var calendarUpdater: CalendarShiftUpdater!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        options = appDelegate.options
        calendarUpdater = appDelegate.calendarUpdater
        
        form +++ calendarSection()
        form +++ shiftSection()
    }
    
    func calendarSection() -> SelectableSection<ListCheckRow<String>> {
        let result = SelectableSection<ListCheckRow<String>>("Shifts Calendar", selectionType: .singleSelection(enableDeselection: false))
        
        let calendars = calendarUpdater.calendars
        for calendar in calendars {
            result <<< ListCheckRow<String> { row in
                row.title = calendar.title
                row.selectableValue = calendar.title
                if calendar.title == options.calendar {
                    row.value = calendar.title
                }
            }
        }
        
        return result
    }
    
    func shiftSection() -> Section {
        
        let section = Section("Shifts")
        
        for template in options.shiftTemplates {
            let shiftButton = ButtonRow(template.shift.description) { row in
                row.title = template.shift.description
                row.cell.accessoryType = .detailDisclosureButton
                }.onCellSelection( { cell,row in
                    let shiftOptionController = ShiftOptionViewController()
                    shiftOptionController.template = template
                    self.navigationController?.show(shiftOptionController, sender: self)
                })
            
            section <<< shiftButton
        }
        
        
        return section
    }
}


class ShiftOptionViewController : FormViewController {
    var template: ShiftTemplate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let description = TextRow("Description") { row in
            row.placeholder = "Description"
            row.value = template?.shift.description
        }
        
        let shortcut = TextRow("Shortcut") { row in
            row.placeholder = "1 character shortcut"
            row.value = template?.shift.shortcut
        }
        
        let color = IntRow { row in
            row.placeholder = "0"
            row.value = 0
        }
        
        form +++ Section("Shift")
            <<< description
            <<< shortcut
            <<< color
    }
    
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            NSLog("here")
        }
    }
    
    
}
