//
//  Extension+ViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    func saveScreenplay() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.annularDeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving"
        
        guard let tracker = GAI.sharedInstance().tracker(withTrackingId: "UA-114892353-1"),
        let saveEvent = GAIDictionaryBuilder.createEvent(withCategory: "Saving", action: "Save", label: "Screenplay", value: 1) else { return }
        
        tracker.send(saveEvent.build() as [NSObject : AnyObject])
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay, completion: { (success) in
                DispatchQueue.main.async {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success"
                        loadingNotification.hide(animated: true, afterDelay: 1)
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed"
                    loadingNotification.hide(animated: true, afterDelay: 1)
                }
            })
        }
    }
    
    
    func getDescriptionCellHeight(with text:String) -> CGFloat {
        let aproximateWidthOfCell = self.view.frame.width // Minus 50 for the leading and trailing margins
        let descriptionSize = CGSize(width: aproximateWidthOfCell, height: 1000)
        let font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        
        let estimatedDescriptionHeight = NSString(string: text).boundingRect(with: descriptionSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font:font, NSAttributedStringKey.paragraphStyle:paragraphStyle], context: nil).height
        if estimatedDescriptionHeight < getDefaultHeightOfCell() {
            return getDefaultHeightOfCell()
        } else {
            return estimatedDescriptionHeight
        }
    }
    
    func getDefaultHeightOfCell() -> CGFloat {
        if self.view.frame.height >= 670 {
            return self.view.frame.height * (1/7)
        } else {
            return self.view.frame.height * (1/7.5)
        }
    }
    
}
