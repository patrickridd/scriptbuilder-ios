//
//  MoPubAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/2/21.
//  Copyright © 2021 patrickridd. All rights reserved.
//

import MoPub

protocol MoPubAdServicLogic {
    func loadBannerAd(with size: CGSize, for delegate: UIViewController) -> MPAdView?
    func loadInterstitial(for delegate: UIViewController) -> AmazonAdInterstitial?
}

struct MoPubAdServic: MoPubAdServicLogic {
   
    func loadBannerAd(with size: CGSize, for delegate: UIViewController) -> MPAdView? {
        
        let bannerView = MPAdView(adUnitId: "db12acb01a204aa8bd15d88017ee921b")
        bannerView?.frame = CGRect(x: 0,
                                   y: 0,
                                   width: kMPPresetMaxAdSizeMatchFrame.width,
                                   height: kMPPresetMaxAdSizeMatchFrame.height)
        return bannerView
    }
    
    func loadInterstitial(for delegate: UIViewController) -> AmazonAdInterstitial? {
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
