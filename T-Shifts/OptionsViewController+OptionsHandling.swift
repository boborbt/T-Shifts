//
//  OptionsViewControllerOptionsHandling.swift
//  T-Shifts
//
//  Created by Roberto Esposito on 28/03/2017.
//  Copyright © 2017 Roberto Esposito. All rights reserved.
//

import Foundation
import UIKit
import os.log
import TShiftsFramework


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
        label.textColor = UIColor.gray
        
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
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
    
    
//    func addCalendarChoiceLine(_ text:String, after anchor: NSLayoutYAxisAnchor) {
//        let button = SSRadioButton()
//        button.setTitle(text, for: .normal)
//        button.contentHorizontalAlignment = .left
//        if #available(iOS 13.0, *) {
//            button.setTitleColor(UIColor.label, for: .normal)
//        } else {
//            button.setTitleColor(UIColor.black, for: .normal)
//        }
//        scrollView.addSubview(button)
//        
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.topAnchor.constraint( equalTo: anchor, constant: Insets.choiceTop ).isActive = true
//        button.leadingAnchor.constraint( equalTo: self.scrollView.leadingAnchor, constant: Insets.choiceLeft ).isActive = true
//        button.trailingAnchor.constraint( equalTo: self.view.trailingAnchor, constant: -Insets.creditsRight).isActive = true
//        
//        if text == options.calendar {
//            button.isSelected = true
//        }
//        
//        calendarOptionsGroup.addButton(button)
//        
//    }
//    
    
    @objc func editTemplateDetails(sender: ShowEditTemplateButton) {
        guard let navigationController = UIApplication.shared.delegate!.window!!.rootViewController as? UINavigationController else { return }
        
        let shiftIndex = shiftsFieldsGroup.firstIndex(where: { field in
            return field.text == sender.field.text
        })!
        
        var shift = shiftsGroup[shiftIndex]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let editTemplateViewController = storyboard.instantiateViewController(withIdentifier: "EditTemplateViewController") as! EditTemplateViewController
    
        shift.description = sender.field.text ?? ""
        editTemplateViewController.shift = shift
        editTemplateViewController.updateShiftCallback = { () in
            self.shiftsGroup[shiftIndex] = editTemplateViewController.shift
        }
                
        navigationController.pushViewController(editTemplateViewController, animated: true)
    }
    
    
    func addShiftTemplateLine( shift: Shift, color: UIColor, after anchor: NSLayoutYAxisAnchor) {
        let field = UITextField()
        let button = ShowEditTemplateButton(field:field)
        
        field.placeholder = LocalizedStrings.shiftNamePlaceholder
        field.text = shift.description
        field.backgroundColor = color.withAlphaComponent(0.1)
        field.layer.borderColor = color.cgColor
        field.layer.borderWidth = 1
        field.layer.cornerRadius = 5
        field.borderStyle = .roundedRect
        field.clearButtonMode = .whileEditing
        field.delegate = self
        field.rightView = button
        field.rightViewMode = .unlessEditing

        scrollView.addSubview(field)
        
        field.translatesAutoresizingMaskIntoConstraints = false
        field.topAnchor.constraint(equalTo: anchor, constant: Insets.fieldTop).isActive = true
        field.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor, constant: Insets.fieldLeft).isActive = true
        field.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.fieldRight).isActive = true
        
        button.setTitle("···", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.frame = CGRect(x:0, y:0, width:28, height:28)
        button.addTarget(self, action: #selector(self.editTemplateDetails(sender:)), for: .touchUpInside)

        
        shiftsFieldsGroup.append(field)
        shiftsGroup.append(shift)
    }
    
    func addAttributedTextView(_ text: NSAttributedString, after anchor: NSLayoutYAxisAnchor) {
        let textView = UITextView()
        textView.attributedText = text
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.textColor = UIColor.gray
        
        scrollView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: anchor, constant: 0).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: Insets.creditsLeft).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -Insets.creditsRight).isActive = true
//        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }

    // Calendar Picker delegates
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.calendarUpdater.calendars.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.calendarUpdater.calendars[row].title
    }
    
    @objc func calendarPickerDonePressed() {
        let row = self.calendarPicker.selectedRow(inComponent: 0)
//        self.pickerView.selectRow(row, inComponent: 0, animated: false)
        self.calendarField.text = self.calendarUpdater.calendars[row].title
        self.calendarField.resignFirstResponder()
    }
    
    @objc func calendarPickerCancelPressed() {
        self.calendarField.resignFirstResponder()
    }
}
