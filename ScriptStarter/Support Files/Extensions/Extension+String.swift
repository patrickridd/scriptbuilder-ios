//
//  Extension+String.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/7/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    public func localized(with argument: String) -> String {
        let localizedString = NSLocalizedString(self,
                                                comment: "")
        return String(format: localizedString,
                      argument)
    }
}
