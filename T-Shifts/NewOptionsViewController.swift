//
//  NewOptionsViewController.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 22/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class NewOptionsViewController: UIViewController {
    struct LocalizedStrings {
        static let shiftCalendarSectionTitle = NSLocalizedString("Shifts Calendar", comment: "Title of section regarding the calendar to be used for storing the shifts")
        static let accessNotGranted = NSLocalizedString("Access to calendars not granted. Please go to Preferences/T-Shifts and enable access to your calendars.", comment: "Error message to be displayed when user did not give access to the calendar")
        static let shiftsSectionTitle = NSLocalizedString("Shifts", comment: "Title of section regarding the names of shifts to be used by the application")
        static let shiftNamePlaceholder = NSLocalizedString("Shift name", comment: "Text displayed on empty text boxes requiring the user to enter the shift name")
        static let calendarSectionInfo = NSLocalizedString("The options below allow you to select one among all the calendars that are available on your phone. Please select the calendar you want to use to store your shifts data. While some user may want to keep all its data into a single calendar, I believe that it makes sense to keep a separate calendar for your shifts. This will make it possible to easily print your shifts using the Calendar Mac Os app excluding all other non-shifts events, or to completely clean up the shift calendar by deleting it without affecting other events. If you do want to use a separate calendar for your shifts and you do not have one yet, you can create one using the standard Calendar app on your device.", comment: "Explanation about why there is the option to select a calendar"
        )
        static let shiftsSectionInfo = NSLocalizedString( "The fields below allow you to customize the names of the events that will appear in your calendar. The app will store events in your calendar using the labels you give using these fields. Importantly, the app will recognize events in your calendar based on those names. For instance, if you manually add one event in your calendar using one of these values as title, the app will show you that event as if your added it in the app itself. Viceversa, if you change one of the labels without updating the titles of events in your calendar, then the will no longer recognize those events.", comment: "Explanation about how to setup shift label names"
        )
    }
    
    struct Insets {
        static let titleTop:CGFloat = 20
        static let titleLeft:CGFloat = 10

        static let infoTop: CGFloat = 5
        static let infoRight:CGFloat = 10
        static let infoLeft:CGFloat = 10
        
        static let fieldLeft: CGFloat = 20
        static let fieldTop: CGFloat = 10
    }
    
    weak var scrollView: UIScrollView!
    weak var options: Options!
    weak var calendarUpdater: CalendarShiftUpdater!
    
    typealias LabelCustomizationBlock = ((UILabel) -> ())
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        options = appDelegate.options
        calendarUpdater = appDelegate.calendarUpdater

        setupScrollView()
        setupCalendarSection()
        setupShiftsSection()
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
        scrollView.contentSize.height = 2000
    }
    
    
    func addSectionTitle(_ title:String, after anchor: NSLayoutYAxisAnchor) {
        let label = UILabel()
        label.text = title
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        scrollView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.titleLeft ).isActive = true
        label.topAnchor.constraint( equalTo: anchor, constant: Insets.titleTop ).isActive = true
        
    }
    
    func addDescriptionLabel(_ text: String, after anchor: NSLayoutYAxisAnchor, _ customize: LabelCustomizationBlock? = nil ) {
        let label = UILabel()
        label.text = text
        
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        scrollView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.infoLeft ).isActive = true
        label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.infoRight).isActive = true
        label.topAnchor.constraint( equalTo: anchor, constant: Insets.infoTop ).isActive = true
        label.numberOfLines = 2
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandLabel(sender:)))
        tapRecognizer.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapRecognizer)
        label.isUserInteractionEnabled = true
        label.textColor = UIColor.gray
        
        customize?(label)
    }
    

    func expandLabel(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        label.numberOfLines = label.numberOfLines == 0 ? 2 : 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.layoutIfNeeded()
        })
    }
    
    func addCalendarChoiceLine(_ text:String, after anchor: NSLayoutYAxisAnchor) {
        let label = UILabel()
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: .body)
        scrollView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.fieldLeft ).isActive = true
        label.topAnchor.constraint( equalTo: anchor, constant: Insets.fieldTop ).isActive = true
        
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
        
        let calendars = calendarUpdater.calendars
        
        for calendar in calendars {
            addCalendarChoiceLine(calendar.title, after: scrollView.subviews.last!.bottomAnchor)
        }
    }
    
    func setupShiftsSection() {
        addSectionTitle(LocalizedStrings.shiftsSectionTitle, after:scrollView.subviews.last!.bottomAnchor)
        addDescriptionLabel(LocalizedStrings.shiftsSectionInfo, after: scrollView.subviews.last!.bottomAnchor)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
