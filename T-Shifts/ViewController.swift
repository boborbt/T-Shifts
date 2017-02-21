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

    @IBOutlet weak var MonthLabel: UILabel!
    @IBOutlet weak var preferenceButton: UIBarButtonItem!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var dayInfoView: DayInfoView!
    
    var detailsDayCellView: DayCellView!
    var markButtonsView: UIView!
    
    
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
        markButtonsView = Bundle.main.loadNibNamed("MarkButtonsView", owner: self, options: nil)!.first as! UIView
        
        dayInfoView.addSubview(detailsDayCellView)
        dayInfoView.addSubview(markButtonsView)
        dayInfoView.setupButtonTaps(controller: self)
        
        setupConstraints()
    }
        
    
    func setupConstraints() {
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
    
    func setupDetailsDayCellView() {
        detailsDayCellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        detailsDayCellView.label.font = UIFont.systemFont(ofSize: 14)
        detailsDayCellView.layer.cornerRadius = 10
        detailsDayCellView.layer.borderColor = UIColor.gray.cgColor
        detailsDayCellView.layer.borderWidth = 1

        calendarView.selectDates([Date()])
    }

    
// MARK: Add/remove shifts
    @IBAction func addShift(_ sender: UIButton) {
        let dates = calendarView.selectedDates
        guard dates.count > 0 else { return }
        let date = dates[0]
        let shift = shiftTemplates.template(at: sender.tag)!.shift
        
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

