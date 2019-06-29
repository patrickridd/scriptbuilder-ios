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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let saveAction = #selector(save)
        self.action = saveAction
    }
    
    @objc func save() {
        if let view = view {
            self.isEnabled = false
            view.saveScreenplay {
                DispatchQueue.main.async {
                    self.isEnabled = true
                }
            }
        }
    }

}
