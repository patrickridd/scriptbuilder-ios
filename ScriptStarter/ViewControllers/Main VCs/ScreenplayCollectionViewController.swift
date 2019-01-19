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
import Hero
import Firebase

class ScreenplayCollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var screenplays: [Screenplay] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var user: FIRUser? {
        return FIRAuth.auth()?.currentUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove Navigation bar shadow and borderline
        // self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        //  self.navigationController?.navigationBar.shadowImage = UIImage()
        //self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.backgroundColor = .white
        
        //  self.navigationController?.navigationBar.backgroundColor = UIColor.clear
        // self.view.backgroundColor = UIColor.groupTableViewBackground
        //self.collectionView.backgroundColor = UIColor.groupTableViewBackground
        getScreenplays()
        
        // Enlarge new screenplay if none exist
        if screenplays.count == 0 {
          //  segueToNewScreenPlay()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.screenLightBlue,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : -2.0,
            NSAttributedString.Key.font: UIFont(name: "Avenir-Light", size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular)]
    
        self.navigationController?.navigationBar.titleTextAttributes = strokeTextAttributes
        self.title = "Script Builder"
        self.collectionView.reloadData()
    }
    
    // MARK: UI Methods
    
    func setStatusBarColor() {
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor.screenDark
        }
    }

    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        
        FBSDKLoginManager().logOut()
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
        self.hero.isEnabled = true
        self.hero.modalAnimationType
            = .selectBy(presenting:.zoom, dismissing:.zoomOut)
        self.present(screenplayPageVC, animated: true, completion: nil)
    }
    
    func getScreenplays() {
        FirebaseController.shared.getScreenplays { (screenplays) in
            DispatchQueue.main.async {
                self.screenplays = screenplays
                if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: self.screenplays) {
                    self.segueTo(screenplay: screenplay)
                }
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.screenLightBlue
        self.navigationController?.navigationBar.backgroundColor = UIColor.screenDark
        
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first, let screenplayCoverVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayCover") as? ScreenplayCoverViewController else { return }
        
        screenplayCoverVC.view.hero.id = "\(indexPath.row)"
        
        if indexPath.row == 0 { return } // Users tapped on "+" screenplay so return
        
        let screenplay = screenplays[indexPath.row-1]
        ScreenplayController.shared.set(currentScreenplay: screenplay)
        
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
            addScreenplayCell.update(heroId: "\(indexPath.row)")
            return addScreenplayCell
        default:
            // TODO: Create a cell for an existing screenplay
            guard let screenplayCell = collectionView.dequeueReusableCell(withReuseIdentifier: "screenplayCell", for: indexPath) as? ScreenplayCollectionViewCell else { return UICollectionViewCell() }
            let screenplay = self.screenplays[indexPath.row-1]
            screenplayCell.update(title: screenplay.title, name: self.user?.displayName ?? "Name", heroId: "\(indexPath.row)")
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



