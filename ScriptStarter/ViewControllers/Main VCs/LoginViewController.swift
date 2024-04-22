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
import Firebase
import MBProgressHUD
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var authenticationStackView: UIStackView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var scriptBuilderLabel: UILabel!
    @IBOutlet weak var textFieldStackCenterYConstraint: NSLayoutConstraint!
    
    
    var loadingNotification = MBProgressHUD()
   
    // Unhashed nonce.
    fileprivate var currentNonce: String?
   
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
        GIDSignIn.sharedInstance()?.presentingViewController = self
        self.googleSignInButton.style = .standard
        self.googleSignInButton.colorScheme = .light
        
        // Set TextFields Delegate
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
        
        // Sets keyboard observers so we can adjust the textfields
        self.addKeyBoardObservers()
        
        // Add toolbars to be able to dismiss keyboard manually
        addToolBar(textField: self.emailTextField)
        addToolBar(textField: self.passwordTextField)

        // Setup Tap Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false // This way the google button will work
        
        let strokeTextAttributes: [NSAttributedString.Key : Any] =
            [NSAttributedString.Key.strokeColor: UIColor.screenLightBlue,
             NSAttributedString.Key.foregroundColor: UIColor.white,
             NSAttributedString.Key.strokeWidth: 3]
        self.scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder".localized,
                                                                    attributes: strokeTextAttributes)
        setupProviderLoginView()
    }
    
    // MARK: UI Methods

    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            self.loadingNotification.mode = .customView
            if success {    
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                let strokeTextAttributes: [NSAttributedString.Key:Any] =
                    [NSAttributedString.Key.strokeColor : UIColor.screenLightBlue,
                     NSAttributedString.Key.foregroundColor : UIColor.white,
                     NSAttributedString.Key.strokeWidth : -2.0]
                self.scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder".localized,
                                                                            attributes: strokeTextAttributes)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed".localized
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
        loginManager.logIn(permissions: [.publicProfile], viewController: self) { [weak self] loginResult in
            switch loginResult {
            case .failed:
                self?.hideActivityIndicator(success: false,
                                            completion: nil)
            case .cancelled:
                self?.hideActivityIndicator(success: false)
                
            case .success(granted: _, declined: _, token: _):
                // Login with Firebase
                guard let tokenString = AccessToken.current?.tokenString else {
                    self?.hideActivityIndicator(success: false)
                    print("Facebook Token String nil")
                    return
                }
                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
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
                self.present(UIAlertControllers.emailAuthenticationError(message: "Complete both fields".localized),
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
            UIApplication.shared.mainWindow?.rootViewController = signUpVC
        }
    }
    
    @IBAction func forgotPasswordTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Forgot password?".localized,
                                                message: "Please enter your email and tap \"OK\" to reset your password".localized,
                                                preferredStyle: .alert)
        alertController.addTextField { [weak self] oldTextField in
            oldTextField.placeholder = "email".localized
            oldTextField.text = self?.emailTextField.text
        }
        
        let confirmAction = UIAlertAction(title: "OK".localized,
                                          style: .default) { [weak alertController, weak self] _ in
                                            guard let alertController = alertController,
                                                let textField = alertController.textFields?.first else { return }
                                            //compare the current password and do action here
                                            
                                            guard let email = textField.text, email != "" else {
                                                self?.present(UIAlertControllers.emailAuthenticationError(message: "Please enter your email".localized),
                                                              animated: true,
                                                              completion: nil)
                                                return
                                            }
                                            self?.showActivityIndicator()
                                            Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
                                                
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
        let cancelAction = UIAlertAction(title: "Cancel".localized,
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
            screenplayCollectionVC.modalPresentationStyle = .fullScreen
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
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
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
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    
    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                               authorizationButtonStyle: .whiteOutline)
        authorizationButton.addTarget(self,
                                      action: #selector(handleAuthorizationAppleIDButtonPress),
                                      for: .touchUpInside)
        self.authenticationStackView.addArrangedSubview(authorizationButton)
    }
    
    @objc
    func handleAuthorizationAppleIDButtonPress() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap { return String(format: "%02x", $0) }.joined()
        
        return hashString
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        
        var charset = Array<String.Element>()
        let string = "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._"
        for char in string {
            charset.append(char)
        }
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            // Sign in with Firebase.
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error.localizedDescription)
                    return
                }
                self.hideActivityIndicator(success: true, completion: {
                    self.presentScreenPlayCollection()
                })
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}
