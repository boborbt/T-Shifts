//
//  ViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 12/01/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import CoreSpotlight
import JTAppleCalendar
import EasyTipView
import os.log
import TShiftsFramework

class MainViewController: UIViewController {
    
    var shiftStorage: ShiftStorage!
    var indexer: SpotlightIndexer!
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
        setupGotoTodayRecognizer()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage.notifyChanges { date in
            self.calendarView.reloadDates([date])
        }
        
        indexer = SpotlightIndexer(shiftStorage: shiftStorage)
                
        self.select(date:Date())
        feedbackGenerator.prepare()
        indexer.addItemsToSpotlightIndex()
    }
    
    
    func setupCalendarView() {
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.register(UINib(nibName:"DayCellView", bundle:nil), forCellWithReuseIdentifier: "DayCellView")
        calendarView.isScrollEnabled = true
        self.select(date: Date())
    }
    
    func setupGotoTodayRecognizer() {
        os_log("Setting up tap recognizer", type: .debug)
        let gr = UITapGestureRecognizer(target: self, action: #selector(self.monthTap(_:)))
        monthLabel.addGestureRecognizer(gr)
        monthLabel.isUserInteractionEnabled = true
    }
    
    @objc func monthTap(_ sender: UITapGestureRecognizer) {
        os_log("Selecting today...", type: .debug)
        let today = Date.today()
        calendarView.selectDates([today])
        calendarView.scrollToDate(today, triggerScrollToDateDelegate: true, animateScroll: true, preferredScrollPosition: nil, completionHandler: nil)
    }
    
    
// MARK: Events
    
    func select(date: Date) {
        calendarView.selectDates([date])
        calendarView.scrollToDate(date, triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, completionHandler: nil)

    }
    
    
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
            os_log(.error, "Cannot add/remove shift -- error caught")
        }
        
        
        let nextDate = date + 1.days()
        let visibleDates = calendarView.visibleDates()
        
        if visibleDates.outdates.firstIndex(where: { date in nextDate.sameDay(as: date.date) }) == nil {
            dayInfoView.animateNextTransition = true
            calendarView.selectDates([nextDate])
        } else {
            dayInfoView.show(date: date)
        }
        
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
    
    func panelDidClose() {
        do {
            let changedDates = try shiftStorage.commit()
            indexer.reindexShifts(for: changedDates)
        } catch let error {
            os_log(.error, "Error: %@", [error])
        }
    }
}

