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
    
    struct LocalizedStrings {
        static let shiftCalendarSectionTitle = NSLocalizedString("Shifts Calendar", comment: "Title of section regarding the calendar to be used for storing the shifts")
        static let accessNotGranted = NSLocalizedString("Access to calendars not granted. Please go to Preferences/T-Shifts and enable access to your calendars.", comment: "Error message to be displayed when user did not give access to the calendar")
        static let shiftsSectionTitle = NSLocalizedString("Shifts", comment: "Title of section regarding the names of shifts to be used by the application")
        static let shiftNamePlaceholder = NSLocalizedString("Shift name", comment: "Text displayed on empty text boxes requiring the user to enter the shift name")
        
    }
    
    weak var options: Options!
    weak var calendarUpdater: CalendarShiftUpdater!
    
    
    override func awakeFromNib() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.optionsController = self
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        options = appDelegate.options
        calendarUpdater = appDelegate.calendarUpdater
        
        self.tableView?.backgroundColor = UIColor.white
        
        form +++ calendarSection()
        form +++ shiftSection()
    }
    
    
    func reloadCalendarSection() {
        form.removeAll()
        form +++ calendarSection()
        form +++ shiftSection()
        tableView?.reloadData()
    }
    
    func calendarSection() -> SelectableSection<ListCheckRow<String>> {
        let result = SelectableSection<ListCheckRow<String>>(LocalizedStrings.shiftCalendarSectionTitle, selectionType: .singleSelection(enableDeselection: false))
        result.tag = "Calendars"
        
        if !CalendarShiftUpdater.isAccessGranted() {
            result <<< LabelRow { row in
                row.title = LocalizedStrings.accessNotGranted
                row.cell.textLabel?.numberOfLines = 0
                row.cell.textLabel?.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
                }.cellUpdate { cell, row in
                row.cell.textLabel?.textColor = UIColor.red
            }
        }
        
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
        
        let section = Section(LocalizedStrings.shiftsSectionTitle)
        section.tag = "Shifts"
        
        let templates = options.shiftTemplates.templates()
        
        for template in templates {
            let textRow = TextRow("Shift_\(template.position)" ) { row in
                    row.value = template.shift.description
                    row.placeholder = LocalizedStrings.shiftNamePlaceholder
                }.cellSetup { cell, row in
                    cell.layer.borderColor = template.color.cgColor
                    cell.layer.borderWidth = 2
                    cell.layer.cornerRadius = 5
                    cell.backgroundColor = template.color.withAlphaComponent(0.1)
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
                options.shiftTemplates.storage[index].shift.description = rowValue
            } else {
                options.shiftTemplates.storage[index].shift.description = ""
            }
        }
        
        appDelegate.reloadOptions()
    }
}

