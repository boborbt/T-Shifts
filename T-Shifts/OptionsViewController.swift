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
import EventKit


class OptionsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
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
        
        static let pleaseHelp = NSLocalizedString("Please help!", comment: "Please help label")
        
        static let openSourceStatement = NSLocalizedString("I have very little time to develop this app. If you are an iOS developer and you are willing to help, please do!", comment: "Text displayed in the Please Help section")
        
        static let creditsMessage = NSLocalizedString("T-Shifts includes the following open source components:", comment: "Text displayed in the credits section")
        
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

    var toolBar: UIToolbar!
    var calendarField: UITextField!
    var calendarPicker: UIPickerView!
    var shiftsFieldsGroup: [UITextField] = []
    var shiftsGroup: [Shift] = []
    
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
        setupOpenSourceSection()
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
        scrollView.backgroundColor = UIColor.systemBackground
        
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

        calendarPicker = UIPickerView()
        calendarPicker.dataSource = self
        calendarPicker.delegate = self
                
        if let currentCalendar =  calendarUpdater.calendars.first(where: { calendar in return calendar.title == options.calendar }){
            calendarPicker.selectRow(self.calendarUpdater.calendars.firstIndex(of: currentCalendar)!, inComponent: 0, animated: false)
        }
        
        let lastView = scrollView.subviews.last!
        
        calendarField = UITextField()
        calendarField.inputView = calendarPicker;

        toolBar = UIToolbar(frame:CGRect(x:0, y:0, width:100, height:100))
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = toolBar.tintColor
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.calendarPickerDonePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.calendarPickerCancelPressed))

        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        

        calendarField.inputAccessoryView = toolBar

        scrollView.addSubview(calendarField)
        calendarField.translatesAutoresizingMaskIntoConstraints = false
        calendarField.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.fieldLeft ).isActive = true
        calendarField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.fieldRight).isActive = true
        calendarField.topAnchor.constraint( equalTo: lastView.bottomAnchor, constant: Insets.fieldTop ).isActive = true
        
        
        calendarField.backgroundColor = calendarField.tintColor.withAlphaComponent(0.1)
        calendarField.layer.borderColor = calendarField.tintColor.cgColor
        calendarField.layer.borderWidth = 1
        calendarField.layer.cornerRadius = 5
        calendarField.borderStyle = .roundedRect
        
        calendarField.text = options.calendar
    }
    
    func setupShiftsSection() {
        addSectionTitle(LocalizedStrings.shiftsSectionTitle, after:scrollView.subviews.last!.bottomAnchor)
        addDescriptionLabel(LocalizedStrings.shiftsSectionInfo, after: scrollView.subviews.last!.bottomAnchor)
        
        let templates = options.shiftTemplates.templates()

        for template in templates {
            addShiftTemplateLine(shift: template.shift, color: template.color, after: scrollView.subviews.last!.bottomAnchor )
        }
    }
    
    func setupCreditsSection() {
        addSectionTitle(LocalizedStrings.credits, after: scrollView.subviews.last!.bottomAnchor)
        addAttributedTextView(NSAttributedString(string: LocalizedStrings.freeAppStatement), after: scrollView.subviews.last!.bottomAnchor)
        
        let attributedString = NSMutableAttributedString(string: LocalizedStrings.creditsMessage)
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String

        attributedString.append(NSMutableAttributedString(string: "\n\n\tJTAppleCalendar\n\tEasyTipView\n\nV\(appVersion ??  "N/A")b\(buildVersion ?? "N/A"), © 2017 Roberto Esposito"))
        
        attributedString.setAsLink(textToFind: "JTAppleCalendar", linkURL: "https://github.com/patchthecode/JTAppleCalendar")
        attributedString.setAsLink(textToFind: "EasyTipView", linkURL: "https://github.com/teodorpatras/EasyTipView")
        
        addAttributedTextView(attributedString, after: scrollView.subviews.last!.bottomAnchor)
    }
    
    func setupOpenSourceSection() {
        addSectionTitle(LocalizedStrings.pleaseHelp, after:scrollView.subviews.last!.bottomAnchor)
        addAttributedTextView(NSAttributedString(string:LocalizedStrings.openSourceStatement), after: scrollView.subviews.last!.bottomAnchor)
        
        let attributedString = NSMutableAttributedString(string:"GitHub repository: https://github.com/boborbt/T-Shifts")
        attributedString.setAsLink(textToFind: "GitHub repository: https://github.com/boborbt/T-Shifts", linkURL:"https://github.com/boborbt/T-Shifts")
        
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
  
// FIXME
//        if let calendar = calendarOptionsGroup.selectedButton()?.titleLabel?.text {
//            options.calendar = calendar
//        }
        
        if let calendarName = calendarField.text {
            options.calendar = calendarName
        }
        
        for (index, shiftField) in shiftsFieldsGroup.enumerated() {
            if let text = shiftField.text  {
                shiftsGroup[index].description = text
                options.shiftTemplates.storage[index].shift = shiftsGroup[index]
            } else {
                options.shiftTemplates.storage[index].shift.description = ""
            }
        }
        
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.syncOptions()
        appDelegate.checkState()
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//    }
}
