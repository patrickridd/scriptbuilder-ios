//
//  ScreenplayCollectionViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import Firebase

class ScreenplayCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var screenplays: [Screenplay] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var user: Firebase.User? {
        return Auth.auth().currentUser
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.screenLightBlue,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : -2.0,
            NSAttributedString.Key.font: UIFont(name: "Avenir-Light",
                                                size: 20) ?? UIFont.systemFont(ofSize: 20,
                                                                               weight: .regular)]
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.screenDark
        appearance.titleTextAttributes = strokeTextAttributes
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        self.navigationItem.title = "Script Builder".localized
    
        self.collectionView.reloadData()

        getScreenplays()
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
                if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: self.screenplays) {
                    self.segueTo(screenplay: screenplay)
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "screenplaySegue" {
            self.navigationController?.navigationBar.topItem?.title = ""
            self.navigationController?.navigationBar.tintColor = UIColor.screenLightBlue
            self.navigationController?.navigationBar.backgroundColor = UIColor.screenDark
            
            guard let indexPath = collectionView.indexPathsForSelectedItems?.first else { return }
            
            if indexPath.row == 0 { return } // Users tapped on "+" screenplay so return
            
            let screenplay = screenplays[indexPath.row-1]
            ScreenplayController.shared.set(currentScreenplay: screenplay)
        } else if segue.identifier == "settingsSegue" {
            guard
                let navController = segue.destination as? UINavigationController,
                let settingsTableViewController = navController.viewControllers.first as? SettingsTableViewController
            else {
                return
            }
            settingsTableViewController.screenplays = self.screenplays
        }
       
    }
    
}

extension ScreenplayCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenplays.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.row {
        case 0:
            // Create the Add '+' screenplay cell
            guard let addScreenplayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "addScreenplayCell", for: indexPath) as? AddScreenplayCollectionViewCell else { return UICollectionViewCell() }
            return addScreenplayCell
        default:
            // TODO: Create a cell for an existing screenplay
            guard let screenplayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenplayCell", for: indexPath) as? ScreenplayCollectionViewCell else { return UICollectionViewCell() }
            let screenplay = self.screenplays[indexPath.row-1]
            screenplayCell.update(title: screenplay.title, name: screenplay.authorName ?? self.user?.displayName ?? "Name")
            return screenplayCell
        }
    }
}

extension ScreenplayCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width * (2/5)
        let height = width * (4/3)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
