//
//  AmazonAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 7/16/20.
//  Copyright © 2020 patrickridd. All rights reserved.
//

import Foundation

protocol AmazonAdServiceLogic {
    func loadBannerAd(with size: CGSize) -> AmazonAdView?
    func loadInterstitial() -> AmazonAdInterstitial
}

struct AmazonAdService: AmazonAdServiceLogic {
   
    func loadBannerAd(with size: CGSize) -> AmazonAdView? {
        let amazonAdView = AmazonAdView(adSize: size)
        let adOptions = AmazonAdOptions()
        
        #if DEBUG
        adOptions.isTestRequest = true
        amazonAdView?.loadAd(adOptions)
        #endif
        
        return amazonAdView
    }
    
    func loadInterstitial() -> AmazonAdInterstitial {
        return AmazonAdInterstitial()
    }
    
}
