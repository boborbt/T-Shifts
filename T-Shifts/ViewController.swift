//
//  ViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    static let SHIFT_VIEW_CELL_ID = "shiftviewcell"
    static let DAY = 60 * 60 * 24.0
    
    
    weak var shiftStorage: ShiftStorage?

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var shiftView: UITableView!
    
    var shiftViewDataSource: ShiftDataSource?
    
    @IBAction func addShift(_ sender: UIBarButtonItem) {
        let charToShiftTitle = [ "M":"Mattino", "P":"Pomeriggio", "N":"Notte", "R": "Riposo"]
        
        
        self.shiftStorage!.add( datePicker.date,
                               value: charToShiftTitle[sender.title!]!)
        datePicker.date = datePicker.date + 1 * ViewController.DAY
    }
    
    @IBAction func updateCalendar(_ sender: Any) {
        let alert = UIAlertController(title: "Updating calendar",
                                      message: "Do you really want to update your calendar with the shifts you entered?",
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .destructive, handler:  { _ in
            CalendarShiftUpdater().update(with: self.shiftStorage!)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in return })

        alert.addAction(ok)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        shiftStorage = delegate.shiftStorage
        shiftViewDataSource = ShiftDataSource(storage: shiftStorage!)
        shiftView.dataSource = shiftViewDataSource!
        shiftView.register(UINib(nibName:"TableViewShiftCell", bundle:nil),
                           forCellReuseIdentifier: ViewController.SHIFT_VIEW_CELL_ID )
        
        shiftStorage!.notifyChanges {
            let sv = self.shiftView!
            sv.reloadData()
            NSLog("num rows: %d", sv.dataSource!.tableView(sv, numberOfRowsInSection: 0))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

