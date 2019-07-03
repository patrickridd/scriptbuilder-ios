//
//  SaveButton.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 6/29/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import UIKit

class SaveButton: UIButton {
    
    weak var view: UIViewController?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setTitleColor(.screenLightBlue,
                      for: .normal)
        setTitleColor(UIColor.screenLightGray,
                      for: .disabled)
        let saveAction = #selector(save)
        self.addTarget(self,
                       action: saveAction,
                       for: .touchUpInside)
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
    
    func enable() {
        self.isEnabled = true
    }
    
    func disable() {
        self.isEnabled = false
    }
}


