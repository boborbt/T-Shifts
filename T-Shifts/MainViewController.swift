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
import WidgetKit
import StoreKit

class MainViewController: UIViewController {
    
    var shiftStorage: ShiftStorage!
    var indexer: SpotlightIndexer!
    weak var calendarUpdater: CalendarShiftUpdater!
    weak var options: Options!

    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var dayInfoView: DayInfoView!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var satLabel: UILabel!
    @IBOutlet weak var sunLabel: UILabel!
    
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    // MARK: setup
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        options = delegate.options
        delegate.mainController = self
        dayInfoView.delegate = self
        
        calendarUpdater = delegate.calendarUpdater
        setupDayLabels()
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
    
    func setupDayLabels() {
        satLabel.layer.cornerRadius = 3
        satLabel.layer.masksToBounds = true
        sunLabel.layer.cornerRadius = 3
        sunLabel.layer.masksToBounds = true
        
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
        
        os_log(.debug, "refreshing the widget timeline")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func panelDidClose() {
        do {
            let changedDates = try shiftStorage.commit()
            indexer.reindexShifts(for: changedDates)
//            TODO: Implement review requests (the problematic part is to understand when
//                  to ask). When the panel closes and the user already used the app for a while
//                  it would be ok (second part is tricky, one might try by storing the date
//                  of first launch in the userdefaults...)
//            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
//            SKStoreReviewController.requestReview(in: scene!)
        } catch let error {
            os_log(.error, "Error: %@", [error])
        }
    }
}

