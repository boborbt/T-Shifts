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
import os.log

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
        result.tag = "Calendars"
        
        let calendars = calendarUpdater.calendars
        for calendar in calendars {
            result <<< ListCheckRow<String>("Calendar_" + calendar.title) { row in
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
        section.tag = "Shifts"
        
        let templates = options.shiftTemplates.templates
        
        for template in templates {
            let textRow = TextRow("Shift_\(template.position)" ) { row in
                    row.value = template.shift.description
                    row.placeholder = "Shift description"
                }.cellSetup { cell, row in
                    cell.backgroundColor = template.color
                }
            
            
            section <<< textRow
        }
        
        
        return section
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let calendarSection = form.sectionBy(tag: "Calendars")!
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        for row in calendarSection {
            if row.baseValue != nil {
                options.calendar = row.baseValue as! String
            }
        }
        
        let shiftsSection = form.sectionBy(tag: "Shifts")!
            
        for (index,row) in shiftsSection.enumerated() {
            if let rowValue = row.baseValue as? String {
                options.shiftTemplates.templates[index].shift.description = rowValue
            } else {
                options.shiftTemplates.templates[index].shift.description = ""
            }
        }
        
        appDelegate.reloadOptions()
    }
}

