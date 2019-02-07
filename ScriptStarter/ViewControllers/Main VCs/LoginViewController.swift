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

class LoginViewController: UIViewController {

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
            self.facebookButton.addTarget(self,
                                     action: #selector(self.facebookButtonTapped),
                                     for: .touchUpInside)
            // Google Sign-in
            GIDSignIn.sharedInstance().delegate = self
            GIDSignIn.sharedInstance().uiDelegate = self
            self.googleSignInButton.style = .iconOnly
            self.googleSignInButton.colorScheme = .light
            
            // Set TextFields Delegate
            self.emailTextField.delegate = self
            self.passwordTextField.delegate = self
            
            // Sets keyboard observers so we can adjust the textfields
            self.addKeyBoardObservers()
            
            // Add toolbars to be able to dismiss keyboard manually
            self.addToolBar(textField: self.emailTextField)
            self.addToolBar(textField: self.passwordTextField)
            
            // Setup Tap Gesture to dismiss keyboard
            let tapGesture = UITapGestureRecognizer(target: self,
                                                    action: #selector(self.dismissKeyboard))
            self.view.addGestureRecognizer(tapGesture)
            tapGesture.cancelsTouchesInView = false // This way the google button will work
            
            let strokeTextAttributes: [NSAttributedString.Key : Any] =
                [NSAttributedString.Key.strokeColor: UIColor.screenLightBlue,
                 NSAttributedString.Key.foregroundColor: UIColor.white,
                 NSAttributedString.Key.strokeWidth: 1]
            self.scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder",
                                                                        attributes: strokeTextAttributes)
    }
    
    // MARK: UI Methods
    
    func showActivityIndicator() {
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
                let strokeTextAttributes: [NSAttributedString.Key:Any] =
                    [NSAttributedString.Key.strokeColor : UIColor.screenLightBlue,
                     NSAttributedString.Key.foregroundColor : UIColor.white,
                     NSAttributedString.Key.strokeWidth : -2.0]
                self.scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder",
                                                                            attributes: strokeTextAttributes)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed"
                self.loadingNotification.hide(animated: true,
                                              afterDelay: 0)
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
                case .failed:
                    self?.hideActivityIndicator(success: false,
                                                completion: nil)

                case .cancelled:
                    self?.hideActivityIndicator(success: false)
        
                case .success( _, _, _):
                    // Login with Firebase
                    let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
                    FIRAuth.auth()?.signIn(with: credential) { [weak self] (user, error) in
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
                self.present(UIAlertControllers.emailAuthenticationError(message: "Complete both fields"),
                                                                         animated: true)
                return
        }
        
        showActivityIndicator()
        FirebaseController.shared.signIn(with: email, password: password) { [weak self] (error, user) in
            if let error = error {
                let alert = UIAlertControllers.emailAuthenticationError(message: error.localizedDescription)
                self?.hideActivityIndicator(success: false)
                self?.present(alert, animated: true,
                              completion: nil)
                return
            }
            self?.hideActivityIndicator(success: true)
            self?.presentScreenPlayCollection()
        }
        
    }
    
    @IBAction func newAccountButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            guard let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signUpVC") as? SignUpViewController else { return }
            UIApplication.shared.keyWindow?.rootViewController = signUpVC
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Forgot password?",
                                                message: "Please enter your email and tap \"OK\" to reset your password",
                                                preferredStyle: .alert)
        alertController.addTextField { [weak self] oldTextField in
            oldTextField.placeholder = "email"
            oldTextField.text = self?.emailTextField.text
        }
        
        let confirmAction = UIAlertAction(title: "OK",
                                          style: .default) { [weak alertController, weak self] _ in
            guard let alertController = alertController,
            let textField = alertController.textFields?.first else { return }
            //compare the current password and do action here
                        
            guard let email = textField.text, email != "" else {
                self?.present(UIAlertControllers.emailAuthenticationError(message: "Please enter your email"),
                             animated: true,
                             completion: nil)
                return
            }
            self?.showActivityIndicator()
            FIRAuth.auth()?.sendPasswordReset(withEmail: email) { [weak self] error in
                
                // If error exists Alert User
                if let error = error {
                    self?.hideActivityIndicator(success: false)
                    self?.present(UIAlertControllers.emailAuthenticationError(message: error.localizedDescription),
                                  animated: true,
                                  completion: nil)
                    // Else let user know the password was reset
                } else {
                    self?.hideActivityIndicator(success: true)
                    self?.present(UIAlertControllers.passwordResetSuccess(email: email),
                                  animated: true,
                                  completion: nil)
                }
            }
        }
        alertController.addAction(confirmAction)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        alertController.addAction(cancelAction)
        present(alertController,
                animated: true,
                completion: nil)
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
        guard let info = notification.userInfo, let duration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.textFieldStackCenterYConstraint.constant = -80
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let info = notification.userInfo, let duration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.textFieldStackCenterYConstraint.constant = 0
        }
    }
    
    func addKeyBoardObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIWindow.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIWindow.keyboardWillHideNotification,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(UIWindow.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIWindow.keyboardWillShowNotification)
    }
    
    
    // MARK: Navigation
    
    func presentScreenPlayCollection() {
        DispatchQueue.main.async {
            guard let screenplayCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else { return }
            self.present(screenplayCollectionVC,
                         animated: true,
                         completion: nil)
        }
    }
}

extension LoginViewController: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!,
              didSignInFor user: GIDGoogleUser!,
              withError error: Error?) {
        
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
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { [weak self] (user, error) in
            if let error = error {
                self?.hideActivityIndicator(success: false)
                print(error)
                return
            }
            self?.hideActivityIndicator(success: true)
            self?.presentScreenPlayCollection()
        }
    }
    
}

extension LoginViewController: GIDSignInUIDelegate {}
