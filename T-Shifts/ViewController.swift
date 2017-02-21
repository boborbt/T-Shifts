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
    weak var shiftStorage: CalendarShiftStorage!
    weak var calendarUpdater: CalendarShiftUpdater!
    weak var options: Options!
    weak var shiftTemplates: ShiftTemplates!

    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var dayDetailsView: UIView!
    
    @IBOutlet weak var MonthLabel: UILabel!
    
    var detailsDayCellView: DayCellView!
    var detailsLabel: UILabel!
    
    
// MARK: setup
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        options = delegate.options
        
        shiftTemplates = delegate.shiftTemplates
        calendarUpdater = delegate.calendarUpdater
        calendarUpdater.requestAccess()
        
        
        setupCalendarView()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage.notifyChanges { date in
            self.calendarView.reloadDates([date])
        }
        
        if options.calendar == "None" {
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
        calendarView.scrollingMode = .stopAtEachCalendarFrameWidth
        calendarView.scrollEnabled = true
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, completionHandler: nil)
        calendarView.selectDates([Date()])
    }
    
    func setupDetailsDayCellView() {
        detailsDayCellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        detailsDayCellView.label.font = UIFont.systemFont(ofSize: 14)
        detailsDayCellView.layer.cornerRadius = 10

        calendarView.selectDates([Date()])
    }

    
// MARK: Add/remove shifts
    @IBAction func addShift(_ sender: UIBarButtonItem) {
        let dates = calendarView.selectedDates
        guard dates.count > 0 else { return }
        let date = dates[0]
        let shift = shiftTemplates.shift(for: sender.tag)!
        
        do {
            if shiftStorage.isPresent(shift: shift, at: date) {
                try shiftStorage.remove(shift: shift, fromDate: date)
            } else {
                try shiftStorage.add( shift: shift, toDate: date )
            }
        } catch {
            NSLog("Cannot add/remove shift -- error caught")
        }
        calendarView.selectDates([date + 1.days()])
    }
    
    

}

