//
//  MoPubAdService.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/2/21.
//  Copyright © 2021 patrickridd. All rights reserved.
//

import MoPub

protocol MoPubAdServiceLogic {
    
    func loadBannerAd() -> MPAdView?
    func loadInterstitial(for delegate: UIViewController) -> MPInterstitialAdController?
    func loadRewardedAd(with id: String, delegate: MPRewardedVideoDelegate) 
    func hasRewardedVideoReady(id: String) -> Bool
    func presentRewardedVideo(using id: String, with viewcontroller: UIViewController)
}



struct MoPubAdService: MoPubAdServiceLogic {
   
    static let characterRewardedVideoId: String = "13a99bbd8f60426486da3c8559e3a71c"
    static let sceneBuilderRewardedVideoId = "7bd84f374341416fb9f82a5c88f8ed88"
    static let bannerAdUnitId: String = "db12acb01a204aa8bd15d88017ee921b"
    static let interstitialAdUnitId: String = "c50d1e815d644c92ab5e719fc2acdd9f"
    
    func hasRewardedVideoReady(id: String) -> Bool {
        MPRewardedVideo.hasAdAvailable(forAdUnitID: id)
    }
    
    func loadBannerAd() -> MPAdView? {
        let bannerView = MPAdView(adUnitId: MoPubAdService.bannerAdUnitId)
        bannerView?.frame = CGRect(x: 0,
                                   y: 0,
                                   width: kMPPresetMaxAdSizeMatchFrame.width,
                                   height: kMPPresetMaxAdSizeMatchFrame.height)
        bannerView?.loadAd()
        return bannerView
    }
    
    func loadInterstitial(for delegate: UIViewController) -> MPInterstitialAdController? {
        let interstitial = MPInterstitialAdController(forAdUnitId: MoPubAdService.interstitialAdUnitId)
        
        interstitial?.delegate = delegate
        interstitial?.loadAd()

        return interstitial
    }
    
    func loadRewardedAd(with id: String, delegate: MPRewardedVideoDelegate) {
        MPRewardedVideo.loadAd(withAdUnitID: id, withMediationSettings: nil)
    }
    
    func presentRewardedVideo(using id: String, with viewcontroller: UIViewController) {
        MPRewardedVideo.presentAd(forAdUnitID: id, from: viewcontroller, with: nil)
    }
    
    
}
