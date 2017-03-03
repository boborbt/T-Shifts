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
    var dayCellView: DayCellView!
    var offscreenCellView: DayCellView!
    var markButtonsArrayView: MarkButtonsArrayView!
    
    var dayCellViewLeadingConstraint: NSLayoutConstraint!
    var offscreenDayCellViewLeadingConstraint: NSLayoutConstraint!
    
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

    func showDetails(from dayCell: DayCellView, animated: Bool) {
        self.offscreenCellView.copyAttributes(from: dayCell)

        self.showNewCell(animated: animated, completion: { _ in
            self.dayCellView.copyAttributes(from: dayCell)
            swap(&self.dayCellView, &self.offscreenCellView)
            swap(&self.dayCellViewLeadingConstraint, &self.offscreenDayCellViewLeadingConstraint)
            
            self.resetDayCellViewsConstraints()
        })
    }
    
    func showNewCell(animated:Bool, completion: @escaping (Bool) -> ()) {
        self.dayCellViewLeadingConstraint.constant = -self.frame.size.height + 5

        if animated {
            UIView.animate(withDuration: 0.2,
                           animations: {
                                self.layoutIfNeeded()
                                },
                            completion: completion)
        }
    }
    
    func newDayCellView() -> DayCellView {
        let cellView = Bundle.main.loadNibNamed("DayCellView", owner: self, options: nil)!.first as! DayCellView
        
        cellView.label.font = UIFont.systemFont(ofSize: 14)
        cellView.layer.cornerRadius = 10
        cellView.layer.borderColor = UIColor.gray.cgColor
        cellView.layer.borderWidth = 0.5
        
        return cellView
    }
    
    
    func addSubviews() {
        dayCellView = newDayCellView()
        offscreenCellView = newDayCellView()

        markButtonsArrayView = Bundle.main.loadNibNamed("MarkButtonsArrayView", owner: self, options: nil)!.first as! MarkButtonsArrayView
        
        self.addSubview(dayCellView)
        self.addSubview(offscreenCellView)
        self.addSubview(markButtonsArrayView)
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
