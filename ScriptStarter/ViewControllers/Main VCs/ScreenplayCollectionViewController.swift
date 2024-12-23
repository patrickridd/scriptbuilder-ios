//
//  ScreenplayCollectionViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Combine
import UIKit
import Firebase
import FBSDKLoginKit
import Firebase
import SwiftUI

class ScreenplayCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!

    private var cancellables: Set<AnyCancellable> = []

    var screenplays: [Screenplay] = [] {
        didSet {
            reloadCollectionView()
        }
    }

    var user: Firebase.User? {
        return Auth.auth().currentUser
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribeToStore()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        imageView.image = Theme.backgroundImage
        
        setupNavigationBarUI()
        getScreenplays()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
    }

    private func subscribeToStore() {
        Store.shared.$purchasedSubscriptions
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadCollectionView()
            }
            .store(in: &cancellables)
        Store.shared.$purchasedNonConsumables
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reloadCollectionView()
            }
            .store(in: &cancellables)
    }

    fileprivate func setupNavigationBarUI() {
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : Theme.scriptBuilderUIColor,
            NSAttributedString.Key.foregroundColor : Theme.navTitleColor,
            NSAttributedString.Key.strokeWidth : -3,
            NSAttributedString.Key.font: UIFont(name: "Avenir-Light",
                                                size: 20) ?? UIFont.systemFont(ofSize: 20,
                                                                               weight: .regular)]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.navigationBarBackground
        appearance.shadowImage = UIImage()
        appearance.titleTextAttributes = strokeTextAttributes
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        navigationItem.title = "Script Builder".localized
    }

    private func cellRestricted(index: Int) -> Bool {
        if index == 0 && screenplays.count == 0 { return false }
        return !Store.shared.allAccessEnabled && (index > 1 || index == 0)
    }

    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        LoginManager().logOut()
        guard let _ = self.presentingViewController else {
            self.navigateToLoginViewController()
            return
        }
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    func segueTo(screenplay: Screenplay) {
        guard let screenplayPageVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else { return }
        
        ScreenplayController.shared.set(currentScreenplay: screenplay)
        screenplayPageVC.modalPresentationStyle = .fullScreen
        self.present(screenplayPageVC, animated: true, completion: nil)
    }
    
    func getScreenplays() {
        FirebaseController.shared.getScreenplays { (screenplays) in
            DispatchQueue.main.async {
                self.screenplays = ScreenplayController.shared.sort(screenplays: screenplays)
                if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: self.screenplays), Store.shared.allAccessEnabled
                {
                    self.segueTo(screenplay: screenplay)
                }
            }
        }
    }

    @objc
    @MainActor
    func reloadCollectionView() {
        collectionView.reloadData()
    }
    
    // MARK: - Navigation

    // Presents InAppPurchase screen to select Subscriptions or Lifetime purchase
    func presentIAPSubscriptionsView() {
        let iapSubscriptionViewController = UIHostingController(rootView: IAPSubscriptionView(presentingViewController: self))
        if UIDevice.current.userInterfaceIdiom == .pad {
            iapSubscriptionViewController.modalPresentationStyle = .fullScreen
        }
        present(iapSubscriptionViewController, animated: true)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingsSegue" {
            guard
                let navController = segue.destination as? UINavigationController,
                let settingsTableViewController = navController.viewControllers.first as? SettingsTableViewController
            else {
                return
            }
            settingsTableViewController.screenplays = self.screenplays
        }
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "settingsSegue":
            return true
        default:
            return false
        }
    }
}

extension ScreenplayCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        screenplays.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            // Create the Add '+' screenplay cell
            guard let addScreenplayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addScreenplayCell", for: indexPath) as? AddScreenplayCollectionViewCell else { return UICollectionViewCell() }
            addScreenplayCell.updateCell(isRestricted: cellRestricted(index: indexPath.row))
            return addScreenplayCell
        default:
            guard let screenplayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenplayCell", for: indexPath) as? ScreenplayCollectionViewCell else { return UICollectionViewCell() }
            let screenplay = self.screenplays[indexPath.row-1]
            screenplayCell.update(title: screenplay.title, name: screenplay.authorName ?? self.user?.displayName ?? "Name", restricted: cellRestricted(index: indexPath.row))
            
            return screenplayCell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if cellRestricted(index: indexPath.row) {
            presentIAPSubscriptionsView()
            return
        }

        guard let screenplayPageVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else { return }
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = Theme.scriptBuilderUIColor
        self.navigationController?.navigationBar.backgroundColor = UIColor.screenDark
        
        // If user's didn't tap "+" for new screenplay, we set the selected screenplay to currentScreenplay
        if indexPath.row != 0 {
            let screenplay = screenplays[indexPath.row-1]
            ScreenplayController.shared.set(currentScreenplay: screenplay)
        }

        screenplayPageVC.modalPresentationStyle = .fullScreen
        self.present(screenplayPageVC, animated: true, completion: nil)
    }
}

extension ScreenplayCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * (2/5)
        let height = width * (4/3)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        20
    }
}
