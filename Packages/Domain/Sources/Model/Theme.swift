//
//  Theme.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import SwiftUI
import UIKit

public class Theme {

    static public var scriptBuilderUIColor: UIColor {
        UIColor(named: "scriptBuilderUIColor") ?? .systemCyan
    }

    static public var scriptBuilderColor: Color {
        Color("scriptBuilderColor")
    }

    // MARK: Backgrounds
    static public var systemBackground: UIColor? {
        UIColor(named: "systemBackground")
    }

    static public var navigationBarBackground: UIColor? {
        UIColor(named: "navigationBarBackground")
    }

    static public var descriptionTextViewBackground: UIColor? {
        UIColor(named: "descriptionTextViewBackground")
    }

    static public var lineSeparatorcolor: UIColor? {
        UIColor(named: "lineSeparatorcolor")
    }

    static public var tableViewBackgroundColor: UIColor? {
        UIColor(named: "tableViewBackgroundColor")
    }

    static public var secondarySystemBackground: UIColor? {
        UIColor(named: "secondarySystemBackground")
    }

    static public var sectionHeaderSeparatorColor: UIColor? {
        UIColor(named: "sectionHeaderSeparatorColor")
    }

    static public var tableViewSectionCollapsedColor: UIColor? {
       navigationBarBackground
    }

    static public var tableViewSectionExpandedColor: UIColor? {
        tableViewBackgroundColor
    }

    static public var enlargedNavigationBarBackground: UIColor? {
        UIColor(named: "enlargedNavigationBarBackground")
    }

    static public var enlargedNavigationDescriptionBackground: UIColor? {
        UIColor(named: "enlargedNavigationDescriptionBackground")
    }

    // MARK: TextColors
    static public var descriptionTextColor: UIColor {
        UIColor(named: "descriptionTextColor") ?? .label
    }

    static public var descriptionPlaceholderTextColor: UIColor {
        UIColor(named: "descriptionPlaceholderTextColor") ?? .separator
    }

    static public var navTitleColor: UIColor {
        UIColor(named: "navTitleColor") ?? .label
    }

    static public var characterNameTextFieldColor: UIColor {
        UIColor(named: "characterNameTextFieldColor") ?? .label
    }

    static public var characterTableViewSeparatorColor: UIColor {
        UIColor(named: "characterTableViewSeparatorColor") ?? .separator
    }

    static public var backgroundImage: UIImage {
        UIImage(named: "screenplayCollectionViewBackground") ?? UIImage()
    }
}
