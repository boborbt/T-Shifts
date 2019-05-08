//
//  EditTemplateViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 03/05/2019.
//  Copyright © 2019 Roberto Esposito. All rights reserved.
//

import UIKit
import os.log

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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
