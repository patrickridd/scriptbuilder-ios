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
import MBProgressHUD

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var scriptBuilderLabel: UILabel!
    @IBOutlet weak var textFieldStackCenterYConstraint: NSLayoutConstraint!
    
    
    var loadingNotification = MBProgressHUD()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        // Setup Facebook sign in buttons
        facebookButton.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        // Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        googleSignInButton.style = .iconOnly
        googleSignInButton.colorScheme = .light
        
        // Set TextFields Delegate
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        // Sets keyboard observers so we can adjust the textfields
        addKeyBoardObservers()
        
        // Add toolbars to be able to dismiss keyboard manually
        addToolBar(textField: self.emailTextField)
        addToolBar(textField: self.passwordTextField)
        
        // Setup Tap Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false // This way the google button will work
        
        // Set Google Analytics Screen Name
        Analytics.setScreenName("Login", screenClass: "LoginViewController")
        
        let strokeTextAttributes: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.strokeColor : UIColor.screenLightBlue,
            NSAttributedStringKey.foregroundColor : UIColor.white,
            NSAttributedStringKey.strokeWidth : 1,
            ]
        
        scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder", attributes: strokeTextAttributes)
    }
    
    // MARK: UI Methods
    
    func showActivityIndicator() {
//        self.activityIndicatorContainerView.isHidden = false
//        self.activityIndicator.isAnimating
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading"
        }
    }
    
    func hideActivityIndicator(success: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.loadingNotification.mode = .customView
            if success {    
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success"
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                let strokeTextAttributes: [NSAttributedStringKey : Any] = [
                    NSAttributedStringKey.strokeColor : UIColor.screenLightBlue,
                    NSAttributedStringKey.foregroundColor : UIColor.white,
                    NSAttributedStringKey.strokeWidth : -2.0,
                    ]
                
                self.scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder", attributes: strokeTextAttributes)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed"
                self.loadingNotification.hide(animated: true, afterDelay: 0)
                completion?()
            }
        }
        
    }
    
    // MARK: IBActions/Target methods
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        showActivityIndicator()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { [weak self] loginResult in
                switch loginResult {
                case .failed(let error):
                    self?.hideActivityIndicator(success: false, completion: nil)
                    #if DEBUG
                        print(error)
                    #endif
                case .cancelled:
                    self?.hideActivityIndicator(success: false)
                    #if DEBUG
                        print("User cancelled login.")
                    #endif
                case .success( _, _, _):
                    #if DEBUG
                        print("Logged in!")
                    #endif
                    // Login with Firebase
                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
                    Auth.auth().signIn(with: credential) { [weak self] (user, error) in
                        if let error = error {
                            self?.hideActivityIndicator(success: false)
                            print(error.localizedDescription)
                            return
                        }
                        self?.hideActivityIndicator(success: true, completion: {
                            self?.presentScreenPlayCollection()
                        })
                    }
                }
        }
    }
    
    @IBAction func loginInButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text,
            let password = passwordTextField.text else {
                self.present(UIAlertControllers.emailAuthenticationError(message: "Needs both fields completed"), animated: true)
                return
        }
        
        showActivityIndicator()
        FirebaseController.shared.signIn(with: email, password: password) { [weak self] (error, user) in
            if let error = error {
                let alert = UIAlertControllers.emailAuthenticationError(message: error.localizedDescription)
                self?.hideActivityIndicator(success: false)
                self?.present(alert, animated: true, completion: nil)
                return
            }
            self?.hideActivityIndicator(success: true)
            self?.presentScreenPlayCollection()
        }
        
    }
    
    @IBAction func newAccountButtonTapped(_ sender: Any) {
        guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as? SignUpViewController else { return }
        UIApplication.shared.keyWindow?.rootViewController = signUpVC
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        guard let email = self.emailTextField.text else {
            return
        }
        showActivityIndicator()
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            
            
            // If error exists Alert User
            if let error = error {
                self?.hideActivityIndicator(success: false)
                self?.present(UIAlertControllers.emailAuthenticationError(message: error.localizedDescription), animated: true, completion: nil)
            // Else let user know the password was reset
            } else {
                self?.hideActivityIndicator(success: true)
                self?.present(UIAlertControllers.passwordResetSuccess(email: email), animated: true, completion: nil)
            }
        }
    }
    
    
    // MARK: GIDSignInDelegate Methods
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user:
        GIDGoogleUser!, withError error: Error?) {
        showActivityIndicator()
        if let error = error {
            hideActivityIndicator(success: false)
            #if DEBUG
                print(error)
            #endif
            return
        }
        
        guard let authentication = user.authentication else {
            self.hideActivityIndicator(success: false)
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { [weak self] (user, error) in
            if let error = error {
                self?.hideActivityIndicator(success: false)
                print(error)
                return
            }
            self?.hideActivityIndicator(success: true)
            self?.presentScreenPlayCollection()
        }
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
    
    // MARK: - Keyboard Delegate methods
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let info = notification.userInfo, let duration: Double = info[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.textFieldStackCenterYConstraint.constant = -80
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let info = notification.userInfo, let duration: Double = info[UIKeyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.textFieldStackCenterYConstraint.constant = 0
        }
    }
    
    func addKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillHide)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIKeyboardWillShow)
    }
    
    
    // MARK: Navigation
    
    func presentScreenPlayCollection() {
        DispatchQueue.main.async {
            guard let screenplayCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else { return }
            self.present(screenplayCollectionVC, animated: true, completion: nil)
        }
    }
}
