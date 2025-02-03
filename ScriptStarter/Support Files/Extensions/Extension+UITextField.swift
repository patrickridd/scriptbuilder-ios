//
//  Extension+UITextField.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

extension UITextField {
    
    // UITextField Toolbar
    func addToolBar() {
        let doneButton = UIBarButtonItem(title: "Done".localized,
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        let toolBar = UIToolbar()
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.scriptBuilderUIColor
        toolBar.setItems([spaceButton, doneButton],
                         animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()

        self.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        self.resignFirstResponder()
    }
    
}
