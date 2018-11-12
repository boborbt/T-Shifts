//
//  ViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import JTAppleCalendar
import EasyTipView
import os.log

class MainViewController: UIViewController {
    
    var shiftStorage: ShiftStorage!
    weak var calendarUpdater: CalendarShiftUpdater!
    weak var options: Options!

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var dayInfoView: DayInfoView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: setup
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        options = delegate.options
        delegate.mainController = self
        dayInfoView.delegate = self
        
        calendarUpdater = delegate.calendarUpdater
        setupCalendarView()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage.notifyChanges { date in
            self.calendarView.reloadDates([date])
        }
                
        calendarView.selectDates([Date()])
        feedbackGenerator.prepare()
        
        setupUserActivity()
    }
    
    
    func setupCalendarView() {
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.register(UINib(nibName:"DayCellView", bundle:nil), forCellWithReuseIdentifier: "DayCellView")
        calendarView.isScrollEnabled = true
        calendarView.selectDates([Date()])
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, completionHandler: nil)
    }
    
    func setupUserActivity() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"        
        var description: [String] = []
        
        for date in [Date.today(), Date.tomorrow()] {
            if let shift = self.shiftStorage.shiftsDescription(at: date) {
                description.append("\(formatter.string(from: date)): \(shift)")
            }
        }
        
        if description.isEmpty {
            return
        }
        

        let userActivity = NSUserActivity(activityType: "org.boborbt.tshift.readshiftactivity")
        userActivity.expirationDate = Date.tomorrow()
        userActivity.isEligibleForPrediction = true
        userActivity.isEligibleForHandoff = true
        userActivity.title = description.joined(separator:"\n")
        userActivity.persistentIdentifier = "org.boborbt.tshift.readshiftactivity.unique"
        userActivity.keywords = ["shifts"]
        self.userActivity = userActivity
        
        self.userActivity!.becomeCurrent()
    }

    
// MARK: Events
    
    
    @IBAction func showOptions(_ sender: UIBarButtonItem) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.showOptions()
    }
    
    @IBAction func addShift(_ sender: UIButton) {
        let dates = calendarView.selectedDates
        guard dates.count > 0 else { return }
        let date = dates[0]
        let shift = options.shiftTemplates.template(at: sender.tag)!.shift
        
        do {
            if shiftStorage.isPresent(shift: shift, at: date) {
                try shiftStorage.remove(shift: shift, fromDate: date)
            } else {
                try shiftStorage.add( shift: shift, toDate: date )
            }
        } catch {
            os_log("Cannot add/remove shift -- error caught")
        }
        
        
        let nextDate = date + 1.days()
        let visibleDates = calendarView.visibleDates()
        
        if visibleDates.outdates.index(where: { date in nextDate.sameDay(as: date.date) }) == nil {
            dayInfoView.animateNextTransition = true
            calendarView.selectDates([nextDate])
        } else {
            dayInfoView.show(date: date)
        }
        
        self.setupUserActivity()
        
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
}

