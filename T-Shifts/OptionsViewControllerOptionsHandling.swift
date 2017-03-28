//
//  OptionsViewControllerOptionsHandling.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 28/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit


extension OptionsViewController {
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
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        label.textColor = UIColor.gray
        customize?(label)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.expandLabel(sender:)))
        tapRecognizer.numberOfTapsRequired = 1
        label.addGestureRecognizer(tapRecognizer)
        
        scrollView.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.infoLeft ).isActive = true
        label.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.infoRight).isActive = true
        label.topAnchor.constraint( equalTo: anchor, constant: Insets.infoTop ).isActive = true
    }
    
    
    func expandLabel(sender: UIGestureRecognizer) {
        let label = sender.view as! UILabel
        label.numberOfLines = label.numberOfLines == 0 ? 2 : 0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.scrollView.layoutIfNeeded()
        })
    }
    
    func addCalendarChoiceLine(_ text:String, after anchor: NSLayoutYAxisAnchor) {
        let button = SSRadioButton()
        button.setTitle(text, for: .normal)
        button.contentHorizontalAlignment = .left
        button.setTitleColor(UIColor.black, for: .normal)
        scrollView.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.fieldLeft ).isActive = true
        button.topAnchor.constraint( equalTo: anchor, constant: Insets.fieldTop ).isActive = true
        button.trailingAnchor.constraint( equalTo: self.view.trailingAnchor, constant: -Insets.fieldRight).isActive = true
        
        if text == options.calendar {
            button.isSelected = true
        }
        
        calendarOptionsGroup.addButton(button)
        
    }
    
    
    
    func addShiftTemplateLine( title: String, color: UIColor, after anchor: NSLayoutYAxisAnchor) {
        let field = UITextField()
        field.placeholder = LocalizedStrings.shiftNamePlaceholder
        field.text = title
        field.backgroundColor = color.withAlphaComponent(0.1)
        field.layer.borderColor = color.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 5
        field.borderStyle = .roundedRect
        field.clearButtonMode = .whileEditing
        field.delegate = self
        
        scrollView.addSubview(field)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.topAnchor.constraint(equalTo: anchor, constant: Insets.fieldTop).isActive = true
        field.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: Insets.fieldLeft).isActive = true
        field.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.fieldRight).isActive = true
        
        shiftsFieldsGroup.append(field)
    }

}
