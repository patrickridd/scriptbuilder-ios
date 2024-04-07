//
//  Theme.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import UIKit

class Theme {
   
    // MARK: Backgrounds
    static var systemBackground: UIColor {
        switch UIApplication.shared.interfaceStyle {
        case .unspecified, .none, .light:
            return .white
        case .dark:
            return UIColor.screenDark
        }
    }

    static var secondarySystemBackground: UIColor {
        switch UIApplication.shared.interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenLightGray
        case .dark:
            return UIColor.screenDarkGray
        }
    }
    
    static var descriptionTextViewBackground: UIColor {
        switch UIApplication.shared.interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenLightGray
        case .dark:
            return UIColor.screenDarkGray
        }
    }
    
    // MARK: TextColors
    static var label: UIColor {
        switch UIApplication.shared.interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.white
        case .dark:
            return UIColor.screenHaitiBlack
        }
    }
    
}
