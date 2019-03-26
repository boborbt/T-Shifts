//
//  NewOptionsViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 22/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import os.log
import TShiftsFramework

class OptionsViewController: UIViewController, UITextFieldDelegate {
    struct LocalizedStrings {
        static let shiftCalendarSectionTitle = NSLocalizedString("Shifts Calendar", comment: "Title of section regarding the calendar to be used for storing the shifts")
        static let accessNotGranted = NSLocalizedString("Access to calendars not granted. Please go to Preferences/T-Shifts and enable access to your calendars.", comment: "Error message to be displayed when user did not give access to the calendar")
        static let shiftsSectionTitle = NSLocalizedString("Shifts", comment: "Title of section regarding the names of shifts to be used by the application")
        static let shiftNamePlaceholder = NSLocalizedString("Shift name", comment: "Text displayed on empty text boxes requiring the user to enter the shift name")
        static let calendarSectionInfo = NSLocalizedString("The options below allow you to select one among all the calendars that are available on your phone. Please select the calendar you want to use to store your shifts data. While some user may want to keep all his/her data into a single calendar, I believe that it makes sense to keep a separate calendar for your shifts. This will make it possible to easily print your shifts using the Calendar Mac Os app excluding all other non-shifts events, or to completely delete the shift calendar without affecting other events. If you do want to use a separate calendar for your shifts and you do not have one yet, you can create one using the standard Calendar app on your device.", comment: "Explanation about why there is the option to select a calendar"
        )
        static let shiftsSectionInfo = NSLocalizedString( "The fields below allow you to customize the names of the events that will appear in your calendar. The app will store events in your calendar using the labels you give using these fields. Importantly, the app will recognize events in your calendar based on those names. For instance, if you manually add one event in your calendar using one of these values as title, the app will show you that event as if you added it in the app itself. Viceversa, if you change one of the labels without updating the titles of events in your calendar, then the app will no longer recognize those events.", comment: "Explanation about how to setup shift label names"
        )
        
        static let done = NSLocalizedString("Done", comment: "Done button text")
        
        static let credits = NSLocalizedString("About", comment: "Credits title label")
        
        static let freeAppStatement = NSLocalizedString("This app is a work of love toward my wife Tiziana who needed an easier way to insert shifts in her calendar. I have no plan to make it paid. I hope you will enjoy it as much as I enjoyed making it.", comment: "Message to the user")
        
        static let creditsMessage = NSLocalizedString("T-Shifts includes the following open source components:\n\n\tJTAppleCalendar\n\tEasyTipView\n\tSSRadioButton\n\n© 2017 Roberto Esposito", comment: "Text displayed in the credits section")
        
        static let askReview = NSLocalizedString("Please rate and/or review T-Shift", comment:"Text for the link in the options view asking the user to review the app.")
        
        static let reviewPolicy = NSLocalizedString("The app itself will never interrupt you asking for ratings.", comment: "Text in the options view explaing the rating policy of th eapp")
    }
    
    struct Insets {
        static let titleTop:CGFloat = 20
        static let titleLeft:CGFloat = 10

        static let infoTop: CGFloat = 5
        static let infoRight: CGFloat = 10
        static let infoLeft: CGFloat = 10
        
        static let choiceLeft: CGFloat = 20
        static let choiceRight: CGFloat = 20
        static let choiceTop: CGFloat = 5
        
        static let fieldLeft: CGFloat = 20
        static let fieldRight: CGFloat = 20
        static let fieldTop: CGFloat = 10
        
        static let doneButtonTop: CGFloat = 30
        static let doneButtonLeft: CGFloat = 20
        static let doneButtonRight: CGFloat = 20
        
        static let creditsTop: CGFloat = 0
        static let creditsLeft: CGFloat = 10
        static let creditsRight: CGFloat = 10
        
        static let marginBottom:CGFloat = 20
    }
    
    // MARK: Properties and types
    
    weak var scrollView: UIScrollView!
    weak var options: Options!
    weak var calendarUpdater: CalendarShiftUpdater!
    var calendarOptionsGroup: SSRadioButtonsController!
    var shiftsFieldsGroup: [UITextField] = []
    
    typealias LabelCustomizationBlock = ((UILabel) -> ())
    
    // MARK: setup
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        options = appDelegate.options
        calendarUpdater = appDelegate.calendarUpdater

        setupScrollView()
        setupCalendarSection()
        setupShiftsSection()
        setupReviewSection()
        setupCreditsSection()
        setupDoneButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewDidLayoutSubviews() {
        let lastView = scrollView.subviews.sorted { v1, v2 in v1.frame.origin.y <= v2.frame.origin.y }.last!
        let height = lastView.frame.origin.y + lastView.frame.height + Insets.marginBottom
        scrollView.contentSize.height = height
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupScrollView() {
        let sc = UIScrollView()
        self.view.addSubview(sc)
        scrollView = sc
        scrollView.backgroundColor = UIColor.white
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    func setupCalendarSection() {
        addSectionTitle(LocalizedStrings.shiftCalendarSectionTitle, after: scrollView.topAnchor)
        
        if !CalendarShiftUpdater.isAccessGranted() {
            addDescriptionLabel(LocalizedStrings.accessNotGranted, after: scrollView.subviews.last!.bottomAnchor) { label in
                label.textColor = UIColor.red
            }
        } else {
            addDescriptionLabel(LocalizedStrings.calendarSectionInfo, after: scrollView.subviews.last!.bottomAnchor)
        }
        
        calendarOptionsGroup = SSRadioButtonsController()
        
        
        let calendars = calendarUpdater.calendars
        
        for calendar in calendars {
            addCalendarChoiceLine(calendar.title, after: scrollView.subviews.last!.bottomAnchor)
        }
    }
    
    func setupShiftsSection() {
        addSectionTitle(LocalizedStrings.shiftsSectionTitle, after:scrollView.subviews.last!.bottomAnchor)
        addDescriptionLabel(LocalizedStrings.shiftsSectionInfo, after: scrollView.subviews.last!.bottomAnchor)
        
        let templates = options.shiftTemplates.templates()

        for template in templates {
            addShiftTemplateLine(title: template.shift.description, color: template.color, after: scrollView.subviews.last!.bottomAnchor )
        }
    }
    
    func setupCreditsSection() {
        addSectionTitle(LocalizedStrings.credits, after: scrollView.subviews.last!.bottomAnchor)
        addAttributedTextView(NSAttributedString(string: LocalizedStrings.freeAppStatement), after: scrollView.subviews.last!.bottomAnchor)
        
        let attributedString = NSMutableAttributedString(string: LocalizedStrings.creditsMessage)
        
        attributedString.setAsLink(textToFind: "JTAppleCalendar", linkURL: "https://patchthecode.github.io")
        attributedString.setAsLink(textToFind: "EasyTipView", linkURL: "https://github.com/teodorpatras/EasyTipView")
        attributedString.setAsLink(textToFind: "SSRadioButton", linkURL: "https://github.com/shamasshahid/SSRadioButtonsController")
        
        addAttributedTextView(attributedString, after: scrollView.subviews.last!.bottomAnchor)
    }
    
    func setupDoneButton() {
        let button = UIButton(type: .system)
        button.setTitle(LocalizedStrings.done, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = self.view.tintColor
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(self.updateApplicationOptionsAndReturn(_:)), for: .touchUpInside)
        
        let lastSubviewBottomAnchor = scrollView.subviews.last!.bottomAnchor
        
        scrollView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Insets.doneButtonLeft).isActive = true
        button.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.doneButtonRight).isActive = true
        button.topAnchor.constraint(equalTo: lastSubviewBottomAnchor, constant: Insets.doneButtonTop).isActive = true
        
    }
    
    func setupReviewSection() {
        let urlString = "https://itunes.apple.com/app/id1217017578?ls=1&mt=8&action=write-review"
        addSectionTitle("Feedback", after: scrollView.subviews.last!.bottomAnchor)
        

        let message = LocalizedStrings.askReview + ". " + LocalizedStrings.reviewPolicy
        let attributedMessage = NSMutableAttributedString(string: message)
        
        attributedMessage.setAsLink(textToFind: LocalizedStrings.askReview, linkURL: urlString)
        addAttributedTextView(attributedMessage, after: scrollView.subviews.last!.bottomAnchor)
    }
    
    // MARK: Events
    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? CGRect {
            var contentInsets = scrollView.contentInset
            contentInsets.bottom = keyboardSize.height
            scrollView.contentInset = contentInsets
            scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        var inset = scrollView.contentInset
        inset.bottom = 0
        
        scrollView.contentInset = inset
        scrollView.scrollIndicatorInsets = inset
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let viewCenter = self.scrollView.frame.height / 2
        let fieldOffset = textField.center.y - viewCenter
        
        scrollView.setContentOffset(CGPoint(x:0,y:fieldOffset), animated: true)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func expandLabel(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        label.numberOfLines = label.numberOfLines == 0 ? 2 : 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.layoutIfNeeded()
        })
    }
    
    @objc func updateApplicationOptionsAndReturn(_ sender: UIEvent) {
        let _ = self.navigationController?.popViewController(animated: true)
        
        if let calendar = calendarOptionsGroup.selectedButton()?.titleLabel?.text {
            options.calendar = calendar
        }
        
        for (index, shiftField) in shiftsFieldsGroup.enumerated() {
            if let text = shiftField.text  {
                options.shiftTemplates.storage[index].shift.description = text
            } else {
                options.shiftTemplates.storage[index].shift.description = ""
            }
        }
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.reloadOptions()
        appDelegate.checkState()
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//    }
}
