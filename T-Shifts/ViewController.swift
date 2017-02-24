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
        calendarUpdater.requestAccess()
        
        setupCalendarView()
        
        shiftStorage = delegate.shiftStorage
        shiftStorage.notifyChanges { date in
            self.calendarView.reloadDates([date])
        }
        
        if options.calendar == "None" {
            UIApplication.shared.sendAction(preferenceButton.action!, to: preferenceButton.target, from: nil, for: nil)
        }
        
        let dayCellView = setupDetailsDayCellView()
        setupDayInfoView(dayCellView)
        
        setupConstraints()
        
        calendarView.selectDates([Date()])
    }
        
    
    func setupConstraints() {
        let detailsDayCellView = dayInfoView.dayCell!
        let markButtonsView = dayInfoView.markButtonsArray!
        
        detailsDayCellView.translatesAutoresizingMaskIntoConstraints = false
        detailsDayCellView.topAnchor.constraint(equalTo: dayInfoView.topAnchor, constant: +5).isActive = true
        detailsDayCellView.bottomAnchor.constraint(equalTo: dayInfoView.bottomAnchor, constant: -5).isActive = true
        detailsDayCellView.leadingAnchor.constraint(equalTo: dayInfoView.leadingAnchor, constant: +5).isActive = true
        detailsDayCellView.widthAnchor.constraint(equalTo: dayInfoView.heightAnchor, constant: -10).isActive = true
        
        
        markButtonsView.translatesAutoresizingMaskIntoConstraints = false
        markButtonsView.leadingAnchor.constraint(equalTo: detailsDayCellView.trailingAnchor, constant: +5).isActive = true
        markButtonsView.topAnchor.constraint(equalTo: dayInfoView.topAnchor).isActive = true
        markButtonsView.bottomAnchor.constraint(equalTo: dayInfoView.bottomAnchor).isActive = true
        markButtonsView.trailingAnchor.constraint(equalTo: dayInfoView.trailingAnchor).isActive = true

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
    
    func setupDetailsDayCellView() -> DayCellView {
        let detailsDayCellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        detailsDayCellView.label.font = UIFont.systemFont(ofSize: 14)
        detailsDayCellView.layer.cornerRadius = 10
        detailsDayCellView.layer.borderColor = UIColor.gray.cgColor
        detailsDayCellView.layer.borderWidth = 0.5
        
        return detailsDayCellView
    }
    
    func setupDayInfoView(_ dayCellView: DayCellView) {
        let markButtonsArrayView = Bundle.main.loadNibNamed("MarkButtonsArrayView", owner: self, options: nil)!.first as! MarkButtonsArrayView
        dayInfoView.addSubview(dayCellView)
        dayInfoView.addSubview(markButtonsArrayView)
        
        dayInfoView.dayCell = dayCellView
        dayInfoView.markButtonsArray = markButtonsArrayView
        
        dayInfoView.setupButtons(controller: self, templates: options.shiftTemplates)
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
        calendarView.selectDates([date + 1.days()])
    }
}

