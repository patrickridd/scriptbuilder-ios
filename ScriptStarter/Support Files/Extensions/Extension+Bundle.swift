//
//  Bundle.swift
//  ScriptStarter
//
//  Created by patrick ridd on 3/16/25.
//  Copyright © 2025 patrickridd. All rights reserved.
//

import Foundation

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}
