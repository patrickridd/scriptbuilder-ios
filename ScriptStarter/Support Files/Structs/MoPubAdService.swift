//
//  MoPubAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/2/21.
//  Copyright © 2021 patrickridd. All rights reserved.
//

import MoPub

protocol MoPubAdServicLogic {
    func loadBannerAd() -> MPAdView?
    func loadInterstitial(for delegate: UIViewController) -> MPInterstitialAdController?
}

struct MoPubAdServic: MoPubAdServicLogic {
   
    func loadBannerAd() -> MPAdView? {
        
        let bannerView = MPAdView(adUnitId: "db12acb01a204aa8bd15d88017ee921b")
        
        bannerView?.frame = CGRect(x: 0,
                                   y: 0,
                                   width: kMPPresetMaxAdSizeMatchFrame.width,
                                   height: kMPPresetMaxAdSizeMatchFrame.height)
        bannerView?.loadAd()
        return bannerView
    }
    
    func loadInterstitial(for delegate: UIViewController) -> MPInterstitialAdController? {
        let interstitial = MPInterstitialAdController(forAdUnitId: "")
        
        interstitial?.delegate = delegate
        
        #if DEBUG
//        adOptions.isTestRequest = true
        #endif
        
        interstitial?.loadAd()

        return interstitial
    }
    
}
