//
//  ScreenplayPageViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/25/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Hero

class ScreenplayPageViewController: UIPageViewController {
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.getScreenplayViewController(with:"screenplayCover"),
                self.getScreenplayViewController(with:"screenplayTabController")]
    }()
    
    private func getScreenplayViewController(with storyboardId: String) -> UIViewController {
        return self.storyboard!.instantiateViewController(withIdentifier: "\(storyboardId)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        if let screenplayCover = orderedViewControllers.first {
            setViewControllers([screenplayCover],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
        
        // Load Views early so that the RewardAd is loaded when the user taps on the CharacterTableViewController and SceneTableViewController
        if let screenplayTab = orderedViewControllers[1] as? ScreenplayTabBarController {
            _ = ((screenplayTab.viewControllers?[0] as!
                UINavigationController).viewControllers.first as! OutlineTableViewController).view
            _ = ((screenplayTab.viewControllers?[1] as!
                UINavigationController).viewControllers.first as! CharacterTableViewController).view
            _ = ((screenplayTab.viewControllers?[2] as!
                UINavigationController).viewControllers.first as! ScenesTableViewController).view
        }
        
        let swipedRightNotification = Notification.Name(swipeRightNotificationKey)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(swipedRight),
                                               name: swipedRightNotification,
                                               object: nil)
        
        let swipedLeftNotification = Notification.Name(swipeLeftNotificationKey)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(swipedLeft),
                                               name: swipedLeftNotification,
                                               object: nil)
    }
    
    // Mark: SwipeLeftDelegate Methods
    
    @objc func swipedLeft() {
        if let screenplayCover = orderedViewControllers.last {
            setViewControllers([screenplayCover],
                               direction: .forward,
                               animated: true,
                               completion: nil)
        }
    }
    
    @objc func swipedRight() {
        if let screenplayCover = orderedViewControllers.first {
            setViewControllers([screenplayCover],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
    }
    
}

extension ScreenplayPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}
