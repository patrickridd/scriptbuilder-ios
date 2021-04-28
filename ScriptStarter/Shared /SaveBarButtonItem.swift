//
//  SaveBarButtonItem.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 5/30/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import UIKit

class SaveBarButtonItem: UIBarButtonItem {
    
    weak var view: UIViewController?
    
    let button: UIButton = UIButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitle("Save",
                        for: .normal)
        button.setTitleColor(.screenLightBlue,
                             for: .normal)
        button.setTitleColor(UIColor.screenLightGray,
                             for: .disabled)
        button.addTarget(self,
                         action: #selector(save),
                         for: .touchUpInside)
        self.customView = button
    }
    
    @objc func save() {
        if let view = view {
            disable()
            view.saveScreenplay {
                DispatchQueue.main.async {
                   self.enable()
                }
            }
        }
    }
    
    func disable() {
        self.isEnabled = false
        self.button.isEnabled = false
    }
    
    func enable() {
        self.isEnabled = true
        self.button.isEnabled = true
    }

}
