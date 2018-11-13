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
        addItemsToSpotlightIndex()
    }
    
    
    func setupCalendarView() {
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        calendarView.register(UINib(nibName:"DayCellView", bundle:nil), forCellWithReuseIdentifier: "DayCellView")
        calendarView.isScrollEnabled = true
        calendarView.selectDates([Date()])
        calendarView.scrollToDate(Date(), triggerScrollToDateDelegate: true, animateScroll: false, preferredScrollPosition: nil, completionHandler: nil)
    }
    
    func addItemsToSpotlightIndex() {
        let calendar = NSCalendar(calendarIdentifier: .gregorian)!
        
        let startDay = calendar.date(byAdding: .day, value: -15, to: Date())!
        var items:[CSSearchableItem] = []
        
        for numDays in 0...30 {
            let date = calendar.date(byAdding: .day, value: numDays, to: startDay )!
            if self.shiftStorage.shifts(at: date).isEmpty {
                continue
            }
            
            let monthFormatter = DateFormatter()
            let dayFormatter = DateFormatter()
            monthFormatter.dateFormat = "LLLL"
            dayFormatter.dateFormat = "d"
            
            
            let attributeSet = CSSearchableItemAttributeSet()
            attributeSet.contentType = "public.calendar-event"
            attributeSet.startDate = date
            attributeSet.endDate = date
            attributeSet.allDay = true
            attributeSet.title = self.shiftStorage.shiftsDescription(at: date)!
            attributeSet.contentDescription = "Shifts for day: \(self.shiftStorage.shiftsDescription(at: date)!)"
            attributeSet.keywords = [monthFormatter.string(from: date), dayFormatter.string(from:date)] + shiftStorage.shifts(at: date).map { shift in return shift.description }

            
            let item = CSSearchableItem(uniqueIdentifier: shiftStorage.uniqueIdentifier(for: date), domainIdentifier: "shifts", attributeSet: attributeSet)
            
            items.append(item)
        }
        
        let index = CSSearchableIndex.default()
        index.indexSearchableItems(items) { (error) in
            if error != nil {
                os_log(.debug, "Cannot index shifts %s", error.debugDescription)
            } else {
                os_log(.debug, "Indexing shifts completed")
            }
        }
    
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
                
        feedbackGenerator.impactOccurred()
        feedbackGenerator.prepare()
    }
}

