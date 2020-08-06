//
//  AmazonAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 7/16/20.
//  Copyright © 2020 patrickridd. All rights reserved.
//

import Foundation

protocol AmazonAdServiceLogic {
    func loadBannerAd(with size: CGSize, for delegate: UIViewController) -> AmazonAdView?
    func loadInterstitial(for delegate: UIViewController) -> AmazonAdInterstitial
}

struct AmazonAdService: AmazonAdServiceLogic {
   
    func loadBannerAd(with size: CGSize, for delegate: UIViewController) -> AmazonAdView? {
        let amazonAdView = AmazonAdView(adSize: size)
        let adOptions = AmazonAdOptions()
        amazonAdView?.delegate = delegate
        
        #if DEBUG
        adOptions.isTestRequest = true
        #endif
        
        amazonAdView?.loadAd(adOptions)
        return amazonAdView
    }
    
    func loadInterstitial(for delegate: UIViewController) -> AmazonAdInterstitial {
        let interstitial = AmazonAdInterstitial()
        let adOptions = AmazonAdOptions()
        interstitial.delegate = delegate
        
        #if DEBUG
        adOptions.isTestRequest = true
        #endif
        
        interstitial.load(adOptions)
        return interstitial
    }
    
}
