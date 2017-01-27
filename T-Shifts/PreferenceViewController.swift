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
    var calendarPickerToolbar = UIToolbar()
    
    weak var calendarUpdater: CalendarShiftUpdater?

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        calendarUpdater = appDelegate.calendarUpdater
        calendarPickerView.dataSource = self
        calendarPickerView.delegate = self
        
        let doneBtn = UIBarButtonItem(title: "Done",
                                  style: .plain,
                                  target: self,
                                  action: #selector(self.dismissPickerView(_:)) )
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        
        calendarPickerToolbar.items = [flex, doneBtn]
        calendarPickerToolbar.barStyle = .default
        calendarPickerToolbar.isUserInteractionEnabled = true
        calendarPickerToolbar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        
        self.defaultCalendar.inputView = calendarPickerView
        self.defaultCalendar.inputAccessoryView = calendarPickerToolbar
        
        // Do any additional setup after loading the view.
    }
    
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
        self.pickerViewUpdateCalendar()
        self.defaultCalendar!.endEditing(true)
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
