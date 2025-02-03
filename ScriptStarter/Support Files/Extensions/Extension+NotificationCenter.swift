//
//  Extension+NotificationCenter.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/30/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import Foundation

extension Notification.Name {

    static let AppWillEnterForeground =
        Notification.Name(rawValue:"appWillEnterForegroundNotificationKey")
    static let ScreenplayUpdated =
        Notification.Name(rawValue: "SaveScreenplayUpdated")

}
