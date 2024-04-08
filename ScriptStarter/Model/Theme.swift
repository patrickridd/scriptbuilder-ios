//
//  Theme.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import UIKit

class Theme {
   
    static var interfaceStyle: UIUserInterfaceStyle? {
        UIApplication.shared.interfaceStyle
    }
    
    // MARK: Backgrounds
    static var systemBackground: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return .white
        case .dark:
            return UIColor.screenDark
        }
    }
    
    static var navigationBarBackground: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return .white
        case .dark:
            return UIColor.darkGray
        }
    }
    
    static var descriptionTextViewBackground: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return .white
        case .dark:
            return UIColor.darkGray
        }
    }
    
    static var lineSeparatorcolor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return .lightGray
        case .dark:
            return UIColor.screenMidnightExpressBlack
        }
    }

    static var tableViewBackgroundColor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenLightGray
        case .dark:
            return UIColor.black
        }
    }
    
    static var secondarySystemBackground: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.white
        case .dark:
            return UIColor.darkGray
        }
    }
    
    static var sectionHeaderSeparatorColor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.athensGray
        case .dark:
            return UIColor.black
        }
    }
    
    static var tableViewSectionCollapsedColor: UIColor {
       navigationBarBackground
    }
    
    static var tableViewSectionExpandedColor: UIColor {
        tableViewBackgroundColor
    }

    // MARK: TextColors
    static var descriptionTextColor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenHaitiBlack
        case .dark:
            return UIColor.white
        }
    }

    static var descriptionPlaceholderTextColor: UIColor {
        UIColor.lightGray
    }
    
    static var navTitleColor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenDark
        case .dark:
            return UIColor.white
        }
    }
    
    static var characterNameTextFieldColor: UIColor {
        switch interfaceStyle {
        case .unspecified, .none, .light:
            return UIColor.screenDarkMediumGray
        case .dark:
            return UIColor.white
        }
    }

    
}
