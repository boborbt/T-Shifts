//
//  PreferenceViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 23/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class PreferenceViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var defaultCalendar: UITextField!
    var calendarPickerView = UIPickerView()
    var pickerDismissToolbar = UIToolbar()
    
    weak var calendarUpdater: CalendarShiftUpdater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        calendarUpdater = appDelegate.calendarUpdater
        
        setupPickerDismissToolbar()
        setupDefaultCalendarInputView()
    }
    
// MARK: Views setup
    
    func setupPickerDismissToolbar() {
        let doneBtn = UIBarButtonItem(title: "Done",
                                      style: .plain,
                                      target: self,
                                      action: #selector(self.dismissPickerView(_:)) )
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        
        pickerDismissToolbar.items = [flex, doneBtn]
        pickerDismissToolbar.barStyle = .default
        pickerDismissToolbar.isUserInteractionEnabled = true
        pickerDismissToolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func setupDefaultCalendarInputView() {
        calendarPickerView.dataSource = self
        calendarPickerView.delegate = self
        
        self.defaultCalendar.inputView = calendarPickerView
        self.defaultCalendar.inputAccessoryView = pickerDismissToolbar
    }
    
// MARK: Picker Delegate and Data Source methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return calendarUpdater!.calendars.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return calendarUpdater!.calendars[row].title
    }
    
    
    
    func pickerViewUpdateCalendar() {
        let row = calendarPickerView.selectedRow(inComponent: 0)
        
        let calendar = calendarUpdater!.calendars[row]
        calendarUpdater?.targetCalendar = calendar
        
        self.defaultCalendar!.text = calendar.title
    }
    
    func dismissPickerView(_ sender:UIBarButtonItem) {
        if defaultCalendar!.isEditing {
            pickerViewUpdateCalendar()
            defaultCalendar!.endEditing(true)
            return
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
