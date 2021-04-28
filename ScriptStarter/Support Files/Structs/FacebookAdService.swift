//
//  FacebookAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 11/18/20.
//  Copyright © 2020 patrickridd. All rights reserved.
//

import Foundation
import FBAudienceNetwork

protocol FacebookAdServiceLogic {
    func loadBannerAd(for view: UIViewController, with size: FBAdSize) -> FBAdView

}

struct FacebookAdService: FacebookAdServiceLogic {
    
    func loadBannerAd(for view: UIViewController, with size: FBAdSize) -> FBAdView {
        return FBAdView(placementID: "388278151632697_1080181805775658",
                        adSize: size,
                        rootViewController: view)
    }
    
}
