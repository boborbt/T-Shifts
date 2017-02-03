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
    weak var calendarUpdater: CalendarShiftUpdater?
    weak var options: Options?

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var shiftView: UITableView!
    
    var shiftViewDataSource: ShiftDataSource?
    var shiftViewDelegate: ShiftTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        options = delegate.options
        
        calendarUpdater = delegate.calendarUpdater
        calendarUpdater!.requestAccess()
        
        
        self.shiftViewDelegate = ShiftTableViewDelegate()
        self.shiftViewDelegate?.selectionCallback = { row in
            let dateSelected = self.shiftStorage!.shifts[row].date
            self.datePicker.date = dateSelected
        }
        
        
        shiftView.delegate = shiftViewDelegate
        
        
        shiftStorage = delegate.shiftStorage
        shiftViewDataSource = ShiftDataSource(storage: shiftStorage!)
        shiftView.dataSource = shiftViewDataSource!
        shiftView.register(UINib(nibName:"TableViewShiftCell", bundle:nil),
                           forCellReuseIdentifier: ViewController.SHIFT_VIEW_CELL_ID )
        
        shiftStorage!.notifyChanges {
            let sv = self.shiftView!
            sv.reloadData()
        }
        
    }

    
    @IBAction func addShift(_ sender: UIBarButtonItem) {
        let date = datePicker.date
        
        shiftStorage!.add( date, value: options!.shiftNames()[sender.title!]!)
        datePicker.date = datePicker.date + 1 * ViewController.DAY
        
        scrollShiftView(toDate:date)
    }
    
    func scrollShiftView(toDate date: Date) {
        if let index = shiftStorage!.indexOfRow(forDate:date) {
            let indexPath = IndexPath( row:index, section:0)
            shiftView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    @IBAction func gotoToday(_ sender: UIButton) {
        datePicker.date = Date()
        scrollShiftView(toDate: datePicker.date)
    }
    
    @IBAction func removeShift(_ sender: UIButton) {
        if let indexPath = shiftView.indexPathForSelectedRow {
            shiftStorage?.remove(shiftStorage!.shifts[indexPath.row].date)
            shiftView.reloadData()
        }
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        let alert = UIAlertController(title: "Clearing shifts",
                                      message: "Do you really want to clear all inserted shifts? This action cannot be undone",
                                      preferredStyle: .alert)
        
        let clear = UIAlertAction(title:"Clear all", style: .destructive, handler: {_ in
            self.shiftStorage!.shifts.removeAll()
            self.shiftView!.reloadData()
        })
        
        let cancel = UIAlertAction(title:"Cancel", style: .cancel, handler: {_ in return} )
        alert.addAction(clear)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        
        self.present(alert, animated:true, completion: nil)
        
    }
    
    
    
    @IBAction func updateCalendar(_ sender: UIButton) {
        if !CalendarShiftUpdater.isAccessGranted() {
            self.showInfoDialog("Access to the calendar has not been granted. Please allow acces in Settings : T-Shifts : Calendar Access")
            return
        }
        
        let alert = UIAlertController(title: "Updating calendar",
                                      message: "Do you really want to update your calendar with the shifts you entered?",
                                      preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "Ok", style: .destructive, handler:  { _ in
            do {
                try self.calendarUpdater!.update(with: self.shiftStorage!)
                self.showInfoDialog("Your shifts have been added to the calendar.")
            } catch CalendarUpdaterError.updateError(let reason) {
                let errorMsg = String.localizedStringWithFormat("An error occurred while adding your shifts to the calendar. Reason: %s", reason)
                self.showInfoDialog(errorMsg)
            } catch {
                self.showInfoDialog("An unexpected error occurred")
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in return })

        alert.addAction(ok)
        alert.addAction(cancel)
        alert.preferredAction = cancel
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showInfoDialog(_ message:String) {
        let alert = UIAlertController(title: "Task completed",
                                      message: message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated:true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

