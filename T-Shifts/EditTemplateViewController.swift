//
//  EditTemplateViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/05/2019.
//  Copyright © 2019 Roberto Esposito. All rights reserved.
//

import UIKit
import os.log
import TShiftsFramework

class EditTemplateViewController: UIViewController {
    
    // MARK: OUTLETS
    
    @IBOutlet weak var shiftDescription: UILabel!
    @IBOutlet weak var timePickersView: UIView!
    
    @IBOutlet weak var allDaySwitch: UISwitch!
    
    @IBOutlet weak var startHourLabel: UILabel!
    @IBOutlet weak var startHourPicker: UIDatePicker!
    @IBOutlet weak var startHourPickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var endHourLabel: UILabel!
    @IBOutlet weak var endHourPicker: UIDatePicker!
    @IBOutlet weak var endHourPickerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var alertSwitch: UISwitch!
    @IBOutlet weak var alertMinutes: UITextField!
    
    // MARK: PROPERTIES
    
    var updateShiftCallback: (() -> ())!
    var hourFormatter: DateFormatter!
    
    var shift: Shift {
        set(shift) {
            let _ = self.view
            self.shiftDescription.text = shift.description
            self.timePickersView.isHidden = shift.isAllDay
            self.allDaySwitch.isOn = shift.isAllDay
            
            var startHour = DateComponents()
            startHour.hour = shift.startTime.hour
            startHour.minute = shift.startTime.minute
            
            var endHour = DateComponents()
            endHour.hour = shift.endTime.hour
            endHour.minute = shift.endTime.minute
            
            let calendar = Calendar.current
            let startDate = calendar.date(from: startHour)!
            let endDate = calendar.date(from:endHour)!
            
            self.startHourPicker.setDate(startDate, animated: false)
            self.endHourPicker.setDate(endDate, animated: false)
            self.alertSwitch.isOn = shift.alert.active
            self.alertMinutes.text = String(shift.alert.minutes)
            
            startHourLabel.text = hourFormatter.string(from: startDate)
            endHourLabel.text = hourFormatter.string(from:endDate)

        }
        
        get {
            var result = Shift()
            let calendar = Calendar.current
            
            result.description = shiftDescription.text!
            result.isAllDay = allDaySwitch.isOn
            
            result.startTime = (  hour: calendar.component(.hour, from: startHourPicker.date),
                                  minute: calendar.component(.minute, from: startHourPicker.date) )
            
            result.endTime = (  hour: calendar.component(.hour, from: endHourPicker.date),
                                minute: calendar.component(.minute, from: endHourPicker.date) )
            
            result.alert.active = alertSwitch.isOn
            result.alert.minutes = Int(alertMinutes.text ?? "60") ?? 60
            
            return result
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePickerSetVisibility(startHourPicker, hidden: true, animated: false)
        datePickerSetVisibility(endHourPicker, hidden: true, animated: false)
        
        hourFormatter = DateFormatter()
        hourFormatter.dateStyle = .none
        hourFormatter.timeStyle = .short
        
        let keypadToolbar: UIToolbar = UIToolbar()
        
        // add a done button to the numberpad
        keypadToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: alertMinutes, action: #selector(UITextField.resignFirstResponder))
        ]
        keypadToolbar.sizeToFit()
        alertMinutes.inputAccessoryView = keypadToolbar
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        updateShiftCallback()
    }
    
    // Updates the UI to reflect that the all-day switch changed value
    @IBAction func allDayChanged(_ sender: UISwitch) {
        UIView.transition(with: timePickersView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.timePickersView.isHidden = self.allDaySwitch.isOn
        }, completion: nil)
    }
    
    // MARK: ACTIONS
    
    @IBAction func fromLabelTap(_ sender: UITapGestureRecognizer) {
        let newState = !startHourPicker.isHidden;
        
        fieldTap(sender)
        datePickerSetVisibility(startHourPicker, hidden: newState, animated: true)
    }
    
    @IBAction func toLabelTap(_ sender: UITapGestureRecognizer) {
        os_log(.debug, "to label tap")
        let newState = !endHourPicker.isHidden;
        
        fieldTap(sender)
        datePickerSetVisibility(endHourPicker, hidden: newState, animated: true)
    }
    
    
    @IBAction func fieldTap(_ sender: Any) {
        datePickerSetVisibility(startHourPicker, hidden: true, animated: true)
        datePickerSetVisibility(endHourPicker, hidden: true, animated: true)
        
        if sender as? UITextField != alertMinutes {
            os_log(.debug, "Resigning first responder")
            alertMinutes.resignFirstResponder()
        }
    }
    // MARK: PICKERS
    
    @IBAction func startHourPickerDidChange(_ sender: UIDatePicker) {
        startHourLabel.text = hourFormatter.string(from: startHourPicker.date)
    }
    
    @IBAction func endHourPickerDidChange(_ sender: UIDatePicker) {
        endHourLabel.text = hourFormatter.string(from: endHourPicker.date)
    }
    
    func datePickerSetVisibility(_ picker: UIDatePicker, hidden: Bool, animated: Bool) {
        guard picker.isHidden != hidden else { return }
        picker.isHidden = hidden
        
        let heightConstraint = (picker == self.startHourPicker ? startHourPickerHeightConstraint : endHourPickerHeightConstraint)
        
        UIView.animate(withDuration: (animated ? 0.5 : 0.0) , animations: {
            heightConstraint!.constant = (hidden ? 0 : 242)
            self.view.layoutIfNeeded()
        })
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
