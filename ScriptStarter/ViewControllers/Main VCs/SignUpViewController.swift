//
//  SignUpViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/24/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit
import FacebookLogin
import GoogleSignIn
import Firebase
import MBProgressHUD

class SignUpViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    
    
    @IBOutlet weak var textFieldStackCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var orViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var scriptBuilderLabel: UILabel!
    
    @IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!
    
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
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        
        // Add toolbars to textfields
        addToolBar(textField: self.emailTextField)
        addToolBar(textField: self.passwordTextField)
        addToolBar(textField: self.firstNameTextField)
        addToolBar(textField: self.lastNameTextField)
        
        // Sets keyboard observers so we can adjust the textfields
        addKeyBoardObservers()
        
        // Setup Tap Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false // This way the google button will work
       
        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.strokeColor : UIColor.screenLightBlue,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : 1,
            ]
        
        scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder".localized, attributes: strokeTextAttributes)
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.loadingNotification.mode = .customView
            if success {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                return
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed".localized
                self.loadingNotification.hide(animated: true, afterDelay: 0)
            }
        }
        
    }
    
    
    // MARK: IBActions/Target methods
    
    @objc func facebookButtonTapped() {
        let loginManager = LoginManager()
        showActivityIndicator()
        loginManager.logIn(readPermissions: [.publicProfile], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                self.hideActivityIndicator(success: false)
                #if DEBUG
                    print(error)
                #endif
            case .cancelled:
                self.hideActivityIndicator(success: false)
                #if DEBUG
                    print("User cancelled login.")
                #endif
            case .success( _, _, _):
                #if DEBUG
                    print("Logged in!")
                #endif
                // Login with Firebase
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
                FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                        self.hideActivityIndicator(success: false)

                        return
                    }
                    self.hideActivityIndicator(success: true)
                    self.presentScreenPlayCollection()
                }
            }
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        guard let firstName = firstNameTextField.text, firstName != "", let lastName = lastNameTextField.text, lastName != "", let email = emailTextField.text, email != "", let password = passwordTextField.text, password != "" else {
            let alert = UIAlertControllers.emailAuthenticationError(message: "Please complete all fields".localized)
            self.present(alert, animated: true, completion: nil)
            return
        }
        showActivityIndicator()
        FirebaseController.shared.createAccount(firstName: firstName, lastName: lastName, withEmail: email, password: password) { (error, user) in
            if let error = error {
                let alert = UIAlertControllers.emailAuthenticationError(message: error.localizedDescription)
                self.hideActivityIndicator(success: false)
                self.present(alert, animated: true, completion: nil)
            }
            self.hideActivityIndicator(success: true)
            self.presentScreenPlayCollection()
        }
    }

    @IBAction func haveAccountButtonTapped(_ sender: Any) {
        DispatchQueue.main.async {
            guard let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController else { return }
            UIApplication.shared.keyWindow?.rootViewController = loginVC
        }
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
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        showActivityIndicator()
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                self.hideActivityIndicator(success: false)
                print(error)
                return
            }
            self.hideActivityIndicator(success: true)
            self.presentScreenPlayCollection()
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
        case firstNameTextField:
            self.lastNameTextField.becomeFirstResponder()
        case lastNameTextField:
            self.emailTextField.becomeFirstResponder()
        case emailTextField:
            self.passwordTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            signUpButtonTapped(textField)
        }
        return true
    }
    
    // MARK: - Keyboard Delegate methods
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let info = notification.userInfo, let duration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
       
        UIView.animate(withDuration: duration) {
           self.orViewCenterYConstraint.constant = -250
            self.topView.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let info = notification.userInfo, let duration: Double = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
      
        UIView.animate(withDuration: duration) {
            self.orViewCenterYConstraint.constant = -75
            self.topView.isHidden = false
        }
    }
    
    func addKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIWindow.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIWindow.keyboardWillHideNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(UIWindow.keyboardWillHideNotification)
        NotificationCenter.default.removeObserver(UIWindow.keyboardWillShowNotification)
    }
    
    
    // MARK: Navigation
    
    func presentScreenPlayCollection() {
        DispatchQueue.main.async {
            guard let screenplayCollectionVC = self.storyboard?.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else { return }
            self.present(screenplayCollectionVC, animated: true, completion: nil)
        }
    }

}
