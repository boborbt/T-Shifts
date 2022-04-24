//
//  DayInfoView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit
import TShiftsFramework

/**
  Collects the methods needed by DayInfoView to work properly
 */
protocol DayInfoViewDelegate: AnyObject {
    ///   Callback method called every time a shift button is pressed
    func dayInfoTapOn(shiftButton: MarkButton)

    /// Invoked by DayInfoView to get the set of templates that are active on a given date
    func templatesForDate(date:Date) -> [ShiftTemplate]
    
    /// Invoked by DayInfoView to get the complete list of available templates
    func templates() -> ShiftTemplates
    
    /// Invoked by DayInfoView to inform that the secure panel has just been closed
    func panelDidClose()
}


/**
 Implements the main panel used to get info and interact with the informations peratining to a given day.
 
 Visually it consists of a magnified DayCell on the left and a set of buttons on the right that reports (and allow one to modify) the current shifts for the selected day.
 */
class DayInfoView: UIView {
    
    struct Aspect {
        static let inset = CGFloat(5.0)
        static let cornerRadius = CGFloat(10.0)
    }
    
    // MARK: properties
    
    private var date: Date!
    weak var delegate: DayInfoViewDelegate! {
        didSet {
            setup()
        }
    }
    
    
    var dayCellView: DayCellView!
    var offscreenCellView: DayCellView!
    var markButtonsArrayView: MarkButtonsArrayView!
    
    // constraints references needed to implement the
    // animations
    var dayCellViewLeadingConstraint: NSLayoutConstraint!
    var offscreenDayCellViewLeadingConstraint: NSLayoutConstraint!

    // Secure Panel
    var securePanelView: UIControl!
    let feedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    var securePanelViewLeadingConstraint: NSLayoutConstraint!

    
    
    // if set to true next show(date:templates:) will animate
    // the transition
    var animateNextTransition: Bool = false
    
    // MARK: setup
    override func awakeFromNib() {
        addSubviews()
        addAutoLayoutConstraints()
        setupSecurePanel()
    }
    
    
    func refresh() {
        setup()
        if date != nil {
            show(date: date)
        }
    }
    
    
    // MARK: show date
    
    func show(date newDate: Date) {
        guard self.date != nil else {
            date = newDate
            return
        }

        let templates = delegate.templatesForDate(date: newDate)

        dateTransition(to: newDate, templates: templates, animate: animateNextTransition, completion: {
            self.activateMarkButtons(templates: templates)
            self.date = newDate
        })
        
        animateNextTransition = false
    }
    
    // MARK: private members
    
    
    private func setup() {
        for markButton in markButtonsArrayView.markButtonsArray {
            markButton.isVisible = false
            let template = delegate.templates().template(at: markButton.tag)!
            
            if template.shift.description != "" {
                markButton.isVisible = true
                markButton.setupTaps(dayInfoDelegate: delegate)
                markButton.setupForTemplate(template: template)
            }
            
        }
    }

    

    
    // MARK: buttons
    
    private func activateMarkButtons(templates:[ShiftTemplate]) {
        for markButton in markButtonsArrayView.markButtonsArray {
            markButton.isActive = false
        }
        
        for template in templates {
            markButtonsArrayView.markButtonsArray[template.position].isActive = true
        }
    }
    
    
    
    private func dateTransition(to newDate: Date,
                                templates: [ShiftTemplate],
                                animate:Bool,
                                completion callback: @escaping () -> ()) {
        let atEndBlock: (Bool) -> () = { _ in
            self.display(cell: self.dayCellView, forDate: newDate, templates: templates)
            swap(&self.dayCellView, &self.offscreenCellView)
            swap(&self.dayCellViewLeadingConstraint, &self.offscreenDayCellViewLeadingConstraint)
            
            self.resetDayCellViewsConstraints()
            
            callback()
        }
        
        display(cell: offscreenCellView, forDate: newDate, templates: templates)
        
        
        self.dayCellViewLeadingConstraint.constant = -self.frame.size.height + Aspect.inset
        if animate {
            UIView.animate(withDuration: 0.2,
                           animations: { self.layoutIfNeeded() },
                           completion:  atEndBlock)
        } else {
            atEndBlock(true)
        }
    }
    
    private func display(cell: DayCellView, forDate newDate: Date, templates: [ShiftTemplate]) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd";
        
        cell.label.text = formatter.string(from: newDate)
        cell.marks = templates
    }
    
    
    
    
    
    private func addSubviews() {
        dayCellView = DayInfoView.makeDayCellView()
        offscreenCellView = DayInfoView.makeDayCellView()
        
        markButtonsArrayView = (Bundle.main.loadNibNamed("MarkButtonsArrayView", owner: self, options: nil)!.first as! MarkButtonsArrayView)
        
        securePanelView = (Bundle.main.loadNibNamed("SecurePanelView", owner: self, options: nil)!.first as! UIControl)
        
        
        self.addSubview(dayCellView)
        self.addSubview(offscreenCellView)
        self.addSubview(markButtonsArrayView)
        self.addSubview(securePanelView)
    }
    
    
    // This dayCellView factory is correctly situated in the DayInfoView class
    // in fact, it is not building generic DayCellViews, but specifically ones
    // that are customized for the DayInfoView dayViews.
    static private func makeDayCellView() -> DayCellView {
        let cellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        
        cellView.label.font = UIFont.systemFont(ofSize: 14)
        cellView.layer.cornerRadius = Aspect.cornerRadius
        if #available(iOS 13.0, *) {
            cellView.layer.borderColor = UIColor.label.cgColor
        } else {
            cellView.layer.borderColor = UIColor.gray.cgColor
        }
        cellView.layer.borderWidth = 0.5
        
        return cellView
    }
    
    private func resetDayCellViewsConstraints() {
        dayCellViewLeadingConstraint.isActive = false
        offscreenDayCellViewLeadingConstraint.isActive = false
        
        dayCellView.removeConstraint(dayCellViewLeadingConstraint)
        offscreenCellView.removeConstraint(offscreenDayCellViewLeadingConstraint)
        
        dayCellViewLeadingConstraint = dayCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Aspect.inset)
        offscreenDayCellViewLeadingConstraint = offscreenCellView.leadingAnchor.constraint(equalTo: dayCellView.trailingAnchor, constant: 2.0 * Aspect.inset)
        
        dayCellViewLeadingConstraint.isActive = true
        offscreenDayCellViewLeadingConstraint.isActive = true
        self.needsUpdateConstraints()
    }
    
    private func addAutoLayoutConstraints() {
        dayCellViewLeadingConstraint = dayCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Aspect.inset)
        offscreenDayCellViewLeadingConstraint = offscreenCellView.leadingAnchor.constraint(equalTo: dayCellView.trailingAnchor, constant: 2 * Aspect.inset)
        
        dayCellView.translatesAutoresizingMaskIntoConstraints = false
        dayCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: Aspect.inset).isActive = true
        dayCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Aspect.inset).isActive = true
        dayCellViewLeadingConstraint.isActive = true
        dayCellView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -2*Aspect.inset).isActive = true
        
        
        offscreenCellView.translatesAutoresizingMaskIntoConstraints = false
        offscreenCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: +Aspect.inset).isActive = true
        offscreenCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Aspect.inset).isActive = true
        
        offscreenDayCellViewLeadingConstraint.isActive = true
        offscreenCellView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -2*Aspect.inset).isActive = true
        
        
        markButtonsArrayView.translatesAutoresizingMaskIntoConstraints = false
        markButtonsArrayView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.size.height + Aspect.inset).isActive = true
        markButtonsArrayView.topAnchor.constraint(equalTo: self.topAnchor, constant: Aspect.inset).isActive = true
        markButtonsArrayView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Aspect.inset).isActive = true
        markButtonsArrayView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Aspect.inset).isActive = true
        
        
        securePanelViewLeadingConstraint = securePanelView.leadingAnchor.constraint(equalTo: markButtonsArrayView.leadingAnchor, constant: -Aspect.inset)
        
        securePanelView.translatesAutoresizingMaskIntoConstraints = false
        securePanelView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        securePanelViewLeadingConstraint.isActive = true
        
        securePanelView.widthAnchor.constraint(equalTo: markButtonsArrayView.widthAnchor, constant: 2*Aspect.inset).isActive = true
        
        securePanelView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    
    
    
}
