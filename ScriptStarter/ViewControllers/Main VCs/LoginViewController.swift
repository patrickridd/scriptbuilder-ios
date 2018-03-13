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
import GoogleSignIn
import Firebase

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if FBSDKAccessToken.current() != nil || Auth.auth().currentUser != nil {
            // User is logged in so present their screenplays
            presentScreenPlayCollection()
        }
        
        // Setup Facebook sign in buttons
        facebookButton.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        // Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = .iconOnly
        
        // Set TextFields Delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Setup Tap Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false // This way the google button will work
        
        // Set Google Analytics Screen Name
        Analytics.setScreenName("Login", screenClass: "LoginViewController")
        
    }
    
    // MARK: IBActions/Target methods
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { loginResult in
                switch loginResult {
                case .failed(let error):
                    #if DEBUG
                        print(error)
                    #endif
                case .cancelled:
                    #if DEBUG
                        print("User cancelled login.")
                    #endif
                case .success( _, _, _):
                    #if DEBUG
                        print("Logged in!")
                    #endif
                    // Login with Firebase
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
                    Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                    }
                }
        }
    }
    
    @IBAction func loginInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        FirebaseController.shared.signIn(with: email, password: password) { (error, user) in
            if let error = error {
                let alert = UIAlertControllers.emailAuthenticationError(message: error.localizedDescription)
                self.present(alert, animated: true, completion: nil)
                return
            }
            self.presentScreenPlayCollection()
        }
        
    }
    
    @IBAction func newAccountButtonTapped(_ sender: Any) {
        guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as? SignUpViewController else { return }
        UIApplication.shared.keyWindow?.rootViewController = signUpVC
    }
    
    // MARK: GIDSignInDelegate Methods
    
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
    
    func setupDynamicLink() {
        // general link params
//        guard let linkString = dictionary[.link]?.text else {
//            print("Link can not be empty!")
//            return
//        }
//
//        guard let link = URL(string: linkString) else { return }
//        let components = DynamicLinkComponents(link: link, domain: ViewController.DYNAMIC_LINK_DOMAIN)
//
//        // analytics params
//        let analyticsParams = DynamicLinkGoogleAnalyticsParameters(
//            source: dictionary[.source]?.text ?? "", medium: dictionary[.medium]?.text ?? "",
//            campaign: dictionary[.campaign]?.text ?? "")
//        analyticsParams.term = dictionary[.term]?.text
//        analyticsParams.content = dictionary[.content]?.text
//        components.analyticsParameters = analyticsParams
//
//        if let bundleID = dictionary[.bundleID]?.text {
//            // iOS params
//            let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
//            iOSParams.fallbackURL = dictionary[.fallbackURL]?.text.flatMap(URL.init)
//            iOSParams.minimumAppVersion = dictionary[.minimumAppVersion]?.text
//            iOSParams.customScheme = dictionary[.customScheme]?.text
//            iOSParams.iPadBundleID = dictionary[.iPadBundleID]?.text
//            iOSParams.iPadFallbackURL = dictionary[.iPadFallbackURL]?.text.flatMap(URL.init)
//            iOSParams.appStoreID = dictionary[.appStoreID]?.text
//            components.iOSParameters = iOSParams
//
//            // iTunesConnect params
//            let appStoreParams = DynamicLinkItunesConnectAnalyticsParameters()
//            appStoreParams.affiliateToken = dictionary[.affiliateToken]?.text
//            appStoreParams.campaignToken = dictionary[.campaignToken]?.text
//            appStoreParams.providerToken = dictionary[.providerToken]?.text
//            components.iTunesConnectParameters = appStoreParams
//        }
//
//        if let packageName = dictionary[.packageName]?.text {
//            // Android params
//            let androidParams = DynamicLinkAndroidParameters(packageName: packageName)
//            androidParams.fallbackURL = dictionary[.androidFallbackURL]?.text.flatMap(URL.init)
//            androidParams.minimumVersion = dictionary[.minimumVersion]?.text.flatMap {Int($0)} ?? 0
//            components.androidParameters = androidParams
//        }
//
//        // social tag params
//        let socialParams = DynamicLinkSocialMetaTagParameters()
//        socialParams.title = dictionary[.title]?.text
//        socialParams.descriptionText = dictionary[.descriptionText]?.text
//        socialParams.imageURL = dictionary[.imageURL]?.text.flatMap(URL.init)
//        components.socialMetaTagParameters = socialParams
//
//        // OtherPlatform params
//        let otherPlatformParams = DynamicLinkOtherPlatformParameters()
//        otherPlatformParams.fallbackUrl = dictionary[.otherFallbackURL]?.text.flatMap(URL.init)
//        components.otherPlatformParameters = otherPlatformParams
//
//        longLink = components.url
//        print(longLink?.absoluteString ?? "")
    }
    
    // MARK: Tap Gesture Recognizer
    
    @objc func dismissKeyboard() {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    // MARK: UITextField Delegate Method
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            self.passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            loginInButtonTapped(textField)
        }
        return true
    }
    
    
    // MARK: Navigation
    
    func presentScreenPlayCollection() {
        DispatchQueue.main.async {
            guard let screenplayCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else { return }
            self.present(screenplayCollectionVC, animated: true, completion: nil)
        }
    }
}
