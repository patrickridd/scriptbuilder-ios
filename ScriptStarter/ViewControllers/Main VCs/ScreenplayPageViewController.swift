//
//  ScreenplayPageViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/25/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Hero
class ScreenplayPageViewController: UIPageViewController, UIPageViewControllerDataSource {

    
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
        
        let swipeNotificationName = Notification.Name(swipeLeftNotificationKey)
        NotificationCenter.default.addObserver(self, selector: #selector(swipedLeft), name: swipeNotificationName, object: nil)
    }
    
    // Mark: SwipeLeftDelegate Methods
    
    @objc func swipedLeft() {
        if let screenplayCover = orderedViewControllers.first {
            setViewControllers([screenplayCover],
                               direction: .reverse,
                               animated: true,
                               completion: nil)
        }
    }

    // MARK: UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        
        guard orderedViewControllersCount > nextIndex else { return nil }
//        if let tabBarViewController = orderedViewControllers[nextIndex] as? ScreenplayTabBarController {
//            tabBarViewController.swipeDelegate = self
//            return tabBarViewController
//        } else {
//        }
        return orderedViewControllers[nextIndex]

    }

    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
//        let screenTabBarController = getScreenplayViewController(with: "screenplayTabController")
//        if screenTabBarController.tabBarController?.selectedIndex == 0 {
//            return nil
//        }
//
//        guard let viewControllerIndex = orderedViewControllers.index(of:viewController) else { return nil }
//
//        let previousIndex = viewControllerIndex - 1
//
//        guard previousIndex >= 0 else { return nil }
//
//        guard orderedViewControllers.count > previousIndex else { return nil }
//
//        return orderedViewControllers[previousIndex]
    }
    
    
}
