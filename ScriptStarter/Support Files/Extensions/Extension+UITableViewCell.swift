//
//  Extension+UITableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

extension UITableViewCell: UITextViewDelegate, UITextFieldDelegate {
    
    // UITextField UITextView
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.scriptBuilderUIColor
        let doneButton = UIBarButtonItem(title: "Done".localized,
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        toolBar.setItems([spaceButton, doneButton],
                         animated: false)
        
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    
    // UITextField Toolbar
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.scriptBuilderUIColor
        let doneButton = UIBarButtonItem(title: "Done".localized,
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        toolBar.setItems([spaceButton, doneButton],
                         animated: false)
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        self.endEditing(true)
    }
    
    @objc func cancelPressed() {
        self.endEditing(true) // or do something
    }
    
}
