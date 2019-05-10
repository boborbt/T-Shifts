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
    
    
    @IBOutlet weak var shiftDescription: UILabel!
    @IBOutlet weak var timePickersView: UIView!
    @IBOutlet weak var allDaySwitch: UISwitch!
    @IBOutlet weak var startHourPicker: UIDatePicker!
    @IBOutlet weak var endHourPicker: UIDatePicker!
    
    var updateShiftCallback: (() -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    // Updates the UI to reflect that the all-day switch changed value
    @IBAction func allDayChanged(_ sender: UISwitch) {
        UIView.transition(with: timePickersView, duration: 0.4, options: .transitionCrossDissolve, animations: {
            self.timePickersView.isHidden = self.allDaySwitch.isOn
        }, completion: nil)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        updateShiftCallback()
    }
    
    
    func setup(for shift: Shift, text:String) {
        let _ = self.view
        self.shiftDescription.text = text
        self.timePickersView.isHidden = shift.isAllDay
        self.allDaySwitch.isOn = shift.isAllDay
        
        var startHour = DateComponents()
        startHour.hour = shift.startTime.hour
        startHour.minute = shift.startTime.minute
        
        var endHour = DateComponents()
        endHour.hour = shift.endTime.hour
        endHour.minute = shift.endTime.minute
        
        let calendar = Calendar.current
        
        self.startHourPicker.setDate(calendar.date(from: startHour)!, animated: false)
        self.endHourPicker.setDate(calendar.date(from:endHour)!, animated: false)

    }
    
    func computeShift() -> Shift {
        var result = Shift()
        let calendar = Calendar.current
        
        result.description = shiftDescription.text!
        result.isAllDay = allDaySwitch.isOn
        
        result.startTime = (  hour: calendar.component(.hour, from: startHourPicker.date),
                             minute: calendar.component(.minute, from: startHourPicker.date) )
        
        result.endTime = (  hour: calendar.component(.hour, from: endHourPicker.date),
                           minute: calendar.component(.minute, from: endHourPicker.date) )
        
        return result
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
