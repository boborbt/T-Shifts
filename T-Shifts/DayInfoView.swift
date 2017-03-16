//
//  DayInfoView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit


protocol DayInfoViewDelegate: class {
    func dayInfoTapOn(shiftButton: MarkButton)
    func templatesForDate(date:Date) -> [ShiftTemplate]
    func templates() -> ShiftTemplates
}

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
    
    
    private var dayCellView: DayCellView!
    private var offscreenCellView: DayCellView!
    private var markButtonsArrayView: MarkButtonsArrayView!
    private var securePanelView: UIControl!
    
    // constraints references needed to implement the
    // animations
    private var dayCellViewLeadingConstraint: NSLayoutConstraint!
    private var offscreenDayCellViewLeadingConstraint: NSLayoutConstraint!
    private var securePanelViewLeadingConstraint: NSLayoutConstraint!
    
    
    // if set to true next show(date:templates:) will animate
    // the transition
    var animateNextTransition: Bool = false
    
    // MARK: setup
    override func awakeFromNib() {
        addSubviews()
        addAutoLayoutConstraints()
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panelPan(recognizer:)))
        
        securePanelView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    func refresh() {
        setup()
        show(date: date)
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

    
    func panelPan(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: securePanelView)
        let direction:CGFloat = self.effectiveUserInterfaceLayoutDirection == .rightToLeft ? -1.0 : 1.0
        
        let left_bound = -Aspect.inset
        let right_bound = markButtonsArrayView.frame.width - Aspect.inset
        
        securePanelViewLeadingConstraint.constant += translation.x * direction
        if securePanelViewLeadingConstraint.constant < left_bound {
            securePanelViewLeadingConstraint.constant = left_bound
        }
        
        if securePanelViewLeadingConstraint.constant > right_bound {
            securePanelViewLeadingConstraint.constant = right_bound
        }
        
        
        if recognizer.state == .ended {
            // we add velocity.x to the current position to simulate
            // a bit of inertia
            let x = CGFloat(securePanelViewLeadingConstraint.constant) + direction * recognizer.velocity(in: securePanelView).x / 10
            
            if abs(x - left_bound) < abs(x - right_bound) {
                securePanelViewLeadingConstraint.constant = left_bound
            } else {
                securePanelViewLeadingConstraint.constant = right_bound
            }
            
            UIView.animate(withDuration: 0.2, animations: { self.layoutIfNeeded() } )
        } else {
            recognizer.setTranslation(CGPoint.zero, in: securePanelView)
            self.layoutIfNeeded()
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
        
        markButtonsArrayView = Bundle.main.loadNibNamed("MarkButtonsArrayView", owner: self, options: nil)!.first as! MarkButtonsArrayView
        
        securePanelView = Bundle.main.loadNibNamed("SecurePanelView", owner: self, options: nil)!.first as! UIControl
        
        
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
        cellView.layer.borderColor = UIColor.gray.cgColor
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
