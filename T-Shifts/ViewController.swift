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

class ViewController: UIViewController {
    weak var shiftStorage: CalendarShiftStorage!
    weak var calendarUpdater: CalendarShiftUpdater!
    weak var options: Options!

    @IBOutlet weak var MonthLabel: UILabel!
    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var dayInfoView: DayInfoView!
       
// MARK: setup
    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate
        options = delegate.options
        delegate.mainController = self
        
        calendarUpdater = delegate.calendarUpdater
        setupCalendarView()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage.notifyChanges { date in
            self.calendarView.reloadDates([date])
        }
        
        if delegate.needsConfiguration {
            UIApplication.shared.sendAction(preferenceButton.action!, to: preferenceButton.target, from: nil, for: nil)
        }
        
        dayInfoView.setupButtons(controller: self, templates: options.shiftTemplates)
        calendarView.selectDates([Date()])
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
    
        
    
// MARK: Events
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
        
        dayInfoView.animateNextTransition = true
        calendarView.selectDates([date + 1.days()])
    }    
}

