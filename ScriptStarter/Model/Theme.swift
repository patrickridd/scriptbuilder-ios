//
//  Theme.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import SwiftUI
import UIKit

class Theme {

    static var interfaceStyle: UIUserInterfaceStyle? {
        UIApplication.shared.interfaceStyle
    }

    static var scriptBuilderUIColor: UIColor {
        UIColor(named: "scriptBuilderUIColor") ?? .systemCyan
    }

    static var scriptBuilderColor: Color {
        Color("scriptBuilderColor")
    }

    // MARK: Backgrounds
    static var systemBackground: UIColor? {
        UIColor(named: "systemBackground")
    }

    static var navigationBarBackground: UIColor? {
        UIColor(named: "navigationBarBackground")
    }

    static var descriptionTextViewBackground: UIColor? {
        UIColor(named: "descriptionTextViewBackground")
    }

    static var lineSeparatorcolor: UIColor? {
        UIColor(named: "lineSeparatorcolor")
    }

    static var tableViewBackgroundColor: UIColor? {
        UIColor(named: "tableViewBackgroundColor")
    }

    static var secondarySystemBackground: UIColor? {
        UIColor(named: "secondarySystemBackground")
    }

    static var sectionHeaderSeparatorColor: UIColor? {
        UIColor(named: "sectionHeaderSeparatorColor")
    }

    static var tableViewSectionCollapsedColor: UIColor? {
       navigationBarBackground
    }

    static var tableViewSectionExpandedColor: UIColor? {
        tableViewBackgroundColor
    }

    static var enlargedNavigationBarBackground: UIColor? {
        UIColor(named: "enlargedNavigationBarBackground")
    }

    static var enlargedNavigationDescriptionBackground: UIColor? {
        UIColor(named: "enlargedNavigationDescriptionBackground")
    }

    // MARK: TextColors
    static var descriptionTextColor: UIColor {
        UIColor(named: "descriptionTextColor") ?? .label
    }

    static var descriptionPlaceholderTextColor: UIColor {
        UIColor(named: "descriptionPlaceholderTextColor") ?? .separator
    }

    static var navTitleColor: UIColor {
        UIColor(named: "navTitleColor") ?? .label
    }

    static var characterNameTextFieldColor: UIColor {
        UIColor(named: "characterNameTextFieldColor") ?? .label
    }

    static var characterTableViewSeparatorColor: UIColor {
        UIColor(named: "characterTableViewSeparatorColor") ?? .separator
    }

    static var backgroundImage: UIImage {
        UIImage(named: "screenplayCollectionViewBackground") ?? UIImage()
    }
}
