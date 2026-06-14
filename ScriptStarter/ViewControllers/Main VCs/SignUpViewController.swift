//
//  SignUpViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/24/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import FirebaseAuthData
import GoogleSignIn
import Firebase
import MBProgressHUD
import AuthenticationServices
import CryptoKit

class SignUpViewController: UIViewController, ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var activityIndicatorContainerView: UIView!
    @IBOutlet weak var authenticationStackView: UIStackView!
    @IBOutlet weak var orViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var scriptBuilderLabel: UILabel!
    
    @IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!
    
    var loadingNotification = MBProgressHUD()
   
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup Facebook sign in buttons
        facebookButton.addTarget(self, action: #selector(facebookButtonTapped), for: .touchUpInside)
        
        // Google Sign-in (updated API no longer uses delegates on shared instance)
        // TODO: Wire up Google Sign-In using the latest GoogleSignIn API if needed.
        // Older code using GIDSignInDelegate/GIDSignInUIDelegate has been removed to fix build.

        googleSignInButton.style = .wide
        googleSignInButton.colorScheme = .dark
        
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
            NSAttributedString.Key.strokeColor : Theme.scriptBuilderUIColor,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.strokeWidth : 3,
        ]
        
        scriptBuilderLabel.attributedText = NSAttributedString(string: "Script Builder".localized, attributes: strokeTextAttributes)
        
        if #available(iOS 13.0, *) {
            setupProviderLoginView()
        } else {
            // Fallback on earlier versions
        }
    }

    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool) {
        DispatchQueue.main.async {
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
//        let loginManager = LoginManager()
//    
//        showActivityIndicator()
//        
//        loginManager.logIn(permissions: [.publicProfile], viewController: self) { (loginResult) in
//            switch loginResult {
//            case .failed(let error):
//                self.hideActivityIndicator(success: false)
//                #if DEBUG
//                print(error)
//                #endif
//            case .cancelled:
//                self.hideActivityIndicator(success: false)
//                #if DEBUG
//                print("User cancelled login.")
//                #endif
//            case .success( _, _, _):
//                #if DEBUG
//                print("Logged in!")
//                #endif
//                // Login with Firebase
//                guard let tokenString = AccessToken.current?.tokenString else {
//                    self.hideActivityIndicator(success: false)
//                    print("Facebook Token String nil")
//                    return
//                }
//
//                let credential = FacebookAuthProvider.credential(withAccessToken: tokenString)
//                Auth.auth().signIn(with: credential) { (user, error) in
//                    
//                    if let error = error {
//                        print(error.localizedDescription)
//                        self.hideActivityIndicator(success: false)
//                        
//                        return
//                    }
//                    self.hideActivityIndicator(success: true)
//                    self.presentScreenPlayCollection()
//                }
//            }
//
//        }
        
//        loginManager.logIn(permissions: ["default"], from: self) { (loginResult, error) in
//            switch loginResult {
//            case .failed(let error):
//                self.hideActivityIndicator(success: false)
//                #if DEBUG
//                    print(error)
//                #endif
//            case .cancelled:
//                self.hideActivityIndicator(success: false)
//                #if DEBUG
//                    print("User cancelled login.")
//                #endif
//            case .success( _, _, _):
//                #if DEBUG
//                    print("Logged in!")
//                #endif
//                // Login with Firebase
//                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString )
//                Auth.auth().signIn(with: credential) { (user, error) in
//
//                    if let error = error {
//                        print(error.localizedDescription)
//                        self.hideActivityIndicator(success: false)
//
//                        return
//                    }
//                    self.hideActivityIndicator(success: true)
//                    self.presentScreenPlayCollection()
//                }
//            }
//        }
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
            UIApplication.shared.mainWindow?.rootViewController = loginVC
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
            screenplayCollectionVC.modalPresentationStyle = .fullScreen
            self.present(screenplayCollectionVC, animated: true, completion: nil)
        }
    }

}

@available(iOS 13.0, *)
extension SignUpViewController: ASAuthorizationControllerDelegate {

    func setupProviderLoginView() {
        let authorizationButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signUp,
                                                               authorizationButtonStyle: .whiteOutline)
        authorizationButton.addTarget(self,
                                      action: #selector(handleAuthorizationAppleIDButtonPress),
                                      for: .touchUpInside)
        authorizationButton.translatesAutoresizingMaskIntoConstraints = false
        authorizationButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.authenticationStackView.insertArrangedSubview(authorizationButton, at: 0)
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
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                print("Unable to fetch identity token")
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                return
//            }
//            // Initialize a Firebase credential.
//            let credential = OAuthProvider.credential(
//                providerID: .apple,
//                idToken: idTokenString,
//                rawNonce: nonce
//            )
//            // Sign in with Firebase.
//            Auth.auth().signIn(with: credential) { (authResult, error) in
//                if let error = error {
//                    // Error. If error.code == .MissingOrInvalidNonce, make sure
//                    // you're sending the SHA256-hashed nonce as a hex string with
//                    // your request to Apple.
//                    print(error.localizedDescription)
//                    return
//                }
//                self.hideActivityIndicator(success: true)
//                self.presentScreenPlayCollection()
//            }
//        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension LoginViewController: InAppPurchaseDelegate {
    func didCompleteTransaction(for productIdentifier: String?, with error: (any Error)?, displayLoadingImage: Bool) {}
    func startingTransaction() {}
}
