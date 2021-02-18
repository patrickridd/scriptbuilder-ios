//
//  Extension+NotificationCenter.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/30/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let IAPHelperPurchaseNotification = Notification.Name(rawValue:"IAPHelperPurchaseNotification")
    static let CheckIfCharacterBuilderIsEnabled = Notification.Name(rawValue:"CheckIfCharacterBuilderIsEnabled")
    static let CheckIfSceneBuilderIsEnabled = Notification.Name(rawValue:"CheckIfSceneBuilderIsEnabled")
    
    static let AppWillEnterBackground =
        Notification.Name(rawValue:"appWillEnterBackgroundNotificationKey")
    static let AppWillEnterForeground =
        Notification.Name(rawValue:"appWillEnterForegroundNotificationKey")
    
}
