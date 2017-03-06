//
//  DayInfoView.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 21/02/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import UIKit

class DayInfoView: UIView {
    weak var controller:ViewController!
    var date: Date!
    
    var dayCellView: DayCellView!
    var offscreenCellView: DayCellView!
    var markButtonsArrayView: MarkButtonsArrayView!
    
    var dayCellViewLeadingConstraint: NSLayoutConstraint!
    var offscreenDayCellViewLeadingConstraint: NSLayoutConstraint!
    
    var animateNextTransition: Bool = false
    
    override func awakeFromNib() {
        addSubviews()
        addAutoLayoutConstraints()
    }
    
    func activateMarkButtons(templates:[ShiftTemplate]) {
        for markButton in markButtonsArrayView.markButtonsArray {
            markButton.isActive = false
        }
        
        for template in templates {
            markButtonsArrayView.markButtonsArray[template.position].isActive = true
        }
    }
    
    func refreshButtons(controller: ViewController, templates:ShiftTemplates) {
        setupButtons(controller: controller, templates: templates)
    }
    
    func show(date newDate: Date, templates: [ShiftTemplate]) {
        guard self.date != nil else {
            date = newDate
            return
        }
    
        dateTransition(to: newDate, templates: templates, animate: animateNextTransition, completion: {
            self.activateMarkButtons(templates: templates)
            self.date = newDate
        })
        
        animateNextTransition = false
    }

    
    func setupButtons(controller:ViewController, templates: ShiftTemplates) {
        for markButton in markButtonsArrayView.markButtonsArray {
            markButton.isVisible = false
            let template = templates.template(at: markButton.tag)!
            
            if template.shift.description != "" {
                markButton.isVisible = true
                markButton.setupTaps(controller: controller)
                markButton.setupForTemplate(template: template)
            }
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
        
        
        self.dayCellViewLeadingConstraint.constant = -self.frame.size.height + 5
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
        
        self.addSubview(dayCellView)
        self.addSubview(offscreenCellView)
        self.addSubview(markButtonsArrayView)
    }
    
    
    // This dayCellView factory is correctly situated in the DayInfoView class
    // in fact, it is not building generic DayCellViews, but specifically ones
    // that are customized for the DayInfoView dayViews.
    static private func makeDayCellView() -> DayCellView {
        let cellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        
        cellView.label.font = UIFont.systemFont(ofSize: 14)
        cellView.layer.cornerRadius = 10
        cellView.layer.borderColor = UIColor.gray.cgColor
        cellView.layer.borderWidth = 0.5
        
        return cellView
    }
    
    private func resetDayCellViewsConstraints() {
        dayCellViewLeadingConstraint.isActive = false
        offscreenDayCellViewLeadingConstraint.isActive = false
        
        dayCellView.removeConstraint(dayCellViewLeadingConstraint)
        offscreenCellView.removeConstraint(offscreenDayCellViewLeadingConstraint)
        
        dayCellViewLeadingConstraint = dayCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: +5)
        offscreenDayCellViewLeadingConstraint = offscreenCellView.leadingAnchor.constraint(equalTo: dayCellView.trailingAnchor, constant: +10)
        
        dayCellViewLeadingConstraint.isActive = true
        offscreenDayCellViewLeadingConstraint.isActive = true
        self.needsUpdateConstraints()
    }
    
    private func addAutoLayoutConstraints() {
        dayCellViewLeadingConstraint = dayCellView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: +5)
        offscreenDayCellViewLeadingConstraint = offscreenCellView.leadingAnchor.constraint(equalTo: dayCellView.trailingAnchor, constant: +10)
        
        dayCellView.translatesAutoresizingMaskIntoConstraints = false
        dayCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: +5).isActive = true
        dayCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        dayCellViewLeadingConstraint.isActive = true
        dayCellView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -10).isActive = true
        
        offscreenCellView.translatesAutoresizingMaskIntoConstraints = false
        offscreenCellView.topAnchor.constraint(equalTo: self.topAnchor, constant: +5).isActive = true
        offscreenCellView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        offscreenDayCellViewLeadingConstraint.isActive = true
        offscreenCellView.widthAnchor.constraint(equalTo: self.heightAnchor, constant: -10).isActive = true

        
        
        markButtonsArrayView.translatesAutoresizingMaskIntoConstraints = false
        markButtonsArrayView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: self.frame.size.height + 5).isActive = true
        markButtonsArrayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        markButtonsArrayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        markButtonsArrayView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    }
    
    
    

}
