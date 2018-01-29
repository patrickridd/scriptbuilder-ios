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

class ScreenplayCollectionViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, HeroViewControllerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var screenplays = [Screenplay]()
    
    var user: User? {
        return Auth.auth().currentUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.title = "Screenplays"
        
        // Enlarge new screenplay if none exist
        if screenplays.count == 0 {
          //  segueToNewScreenPlay()
        }
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
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        FBSDKLoginManager().logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func segueToNewScreenPlay() {
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            guard let screenplayPageVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayPageVC") as? ScreenplayPageViewController else { return }
            
            // TODO: Set screenplay object if it exists
            self.isHeroEnabled = true
            self.heroModalAnimationType = .selectBy(presenting:.zoom, dismissing:.zoomOut)
    
        }
    }
    
    // MARK - UICollectionViewDataSource
    

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
            // Create a cell for an existing screenplay
            return UICollectionViewCell()
        }
    }
    
    // MARK: - HeroViewControllerDelegate Methods
    
    func heroDidEndTransition() {
         //   setStatusBarColor()
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.screenLightBlue
        self.navigationController?.navigationBar.backgroundColor = UIColor.screenDark
    }
}
