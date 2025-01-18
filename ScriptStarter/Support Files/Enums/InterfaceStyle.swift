//
//  InterfaceStyle.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/25/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import UIKit

enum InterfaceStyle: Int {
    static var userDefaultsKey: String {
        "InterfaceStyle"
    }

    case defaultSelected = 0
    case lightModeSelected = 1
    case darkModeSelected = 2

    var systemInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .defaultSelected:
            return .unspecified
        case .lightModeSelected:
            return .light
        case .darkModeSelected:
            return .dark
        }
    }
}
