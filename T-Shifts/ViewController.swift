//
//  ViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import JTAppleCalendar

class ViewController: UIViewController {
    static let DAY = 60 * 60 * 24.0
    
    
    weak var shiftStorage: ShiftStorage?
    weak var calendarUpdater: CalendarShiftUpdater?
    weak var options: Options?

    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var dayDetailsView: UIView!
    
    var detailsDayCellView: DayCellView!
    var detailsLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        options = delegate.options
        
        calendarUpdater = delegate.calendarUpdater
        calendarUpdater!.requestAccess()
        
        
        setupCalendarView()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage!.notifyChanges {
            self.calendarView.reloadData()
        }
        
        if options!.calendar == "None" {
            UIApplication.shared.sendAction(preferenceButton.action!, to: preferenceButton.target, from: nil, for: nil)
        }
        
        setupDetailsDayCellView()

        detailsLabel = UILabel()
        detailsLabel.text = "Test"

        dayDetailsView.addSubview(detailsDayCellView)
        dayDetailsView.addSubview(detailsLabel)
        setupConstraints()
    }
    
    
    func setupConstraints() {
        detailsDayCellView.translatesAutoresizingMaskIntoConstraints = false
        detailsDayCellView.topAnchor.constraint(equalTo: dayDetailsView.topAnchor, constant: +5).isActive = true
        detailsDayCellView.bottomAnchor.constraint(equalTo: dayDetailsView.bottomAnchor, constant: -5).isActive = true
        detailsDayCellView.leadingAnchor.constraint(equalTo: dayDetailsView.leadingAnchor, constant: +5).isActive = true
        detailsDayCellView.widthAnchor.constraint(equalTo: dayDetailsView.heightAnchor, constant: -10).isActive = true
        
        
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        detailsLabel.centerYAnchor.constraint(equalTo: dayDetailsView.centerYAnchor).isActive = true
        detailsLabel.leadingAnchor.constraint(equalTo: detailsDayCellView.trailingAnchor, constant: +5).isActive = true

    }
    
    func setupCalendarView() {
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "DayCellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
    }
    
    func setupDetailsDayCellView() {
        detailsDayCellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        detailsDayCellView.label.font = UIFont.systemFont(ofSize: 14)
        detailsDayCellView.layer.cornerRadius = 10

        calendarView.selectDates([Date()])
    }

    
    @IBAction func addShift(_ sender: UIBarButtonItem) {
        let dates = calendarView.selectedDates
        if dates.count == 0 {
            return
        }
        
        let date = dates[0]
        
        shiftStorage!.add( date, value: options!.shiftNames[sender.title!]!)
        calendarView.selectDates([date + 1 * ViewController.DAY], triggerSelectionDelegate: true)
    }
    
    @IBAction func gotoToday(_ sender: UIButton) {
        calendarView.selectDates([Date()])
    }
    
    @IBAction func removeShift(_ sender: UIButton) {
        if calendarView.selectedDates.count == 0 { return }
        let date = calendarView.selectedDates.first!
        if shiftStorage?.shift(forDate: date) == nil { return }
        
        shiftStorage!.remove(date)
    }
    
    @IBAction func clearAll(_ sender: UIButton) {
        let alert = UIAlertController(title: "Clearing shifts",
                                      message: "Do you really want to clear all inserted shifts? This action cannot be undone",
                                      preferredStyle: .alert)
        
        let clear = UIAlertAction(title:"Clear all", style: .destructive, handler: {_ in
            self.shiftStorage!.shifts.removeAll()
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

