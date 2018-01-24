//
//  LoginViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FacebookLogin
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate, FBSDKLoginButtonDelegate {

    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil || Auth.auth().currentUser != nil {
            // User is logged in so present their screenplays
            presentScreenPlayCollection()
        }
        
        // Setup Facebook sign in buttons
        facebookButton.delegate = self
        
        //facebookButton.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        // Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = .standard
    }
    
    // MARK: IBActions/Target methods
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if result.isCancelled { return }

        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.presentScreenPlayCollection()
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
//    @objc func facebookButtonTapped() {
//        let loginManager = LoginManager()
//        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { loginResult in
//                switch loginResult {
//                case .failed(let error):
//                    #if DEBUG
//                        print(error)
//                    #endif
//                case .cancelled:
//                    #if DEBUG
//                        print("User cancelled login.")
//                    #endif
//                case .success( _, _, _):
//                    #if DEBUG
//                        print("Logged in!")
//                    #endif
//
//
//                }
//        }
//    }
    
    // MARK:  GIDSignInDelegate Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            #if DEBUG
                print(error)
            #endif
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                print(error)
                return
            }
            self.presentScreenPlayCollection()
        }
    }
    
    // MARK: Navigation
    
    func presentScreenPlayCollection() {
        DispatchQueue.main.async {
            guard let screenplayCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else { return }
            self.present(screenplayCollectionVC, animated: true, completion: nil)
        }
    }
    
}
