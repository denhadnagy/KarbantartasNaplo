//
//  ViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 10..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var loginLabel: UILabel!
    @IBOutlet private weak var loginScrollView: UIScrollView!
    @IBOutlet private weak var emailTextField: MyTextField!
    @IBOutlet private weak var passwordTextField: MyTextField!
    @IBOutlet private weak var loginFailedLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var signUpTextView: UITextView!
    
    @IBOutlet private weak var loginScrollViewHeight: NSLayoutConstraint!
    
    @IBOutlet private weak var logoImageViewTopCR: NSLayoutConstraint!
    @IBOutlet private weak var logoImageViewHeightCR: NSLayoutConstraint!
    @IBOutlet private weak var loginLabelTopCR: NSLayoutConstraint!
    
    @IBOutlet private weak var loginLabelTopRC: NSLayoutConstraint!
    @IBOutlet private weak var loginLabelBottomRC: NSLayoutConstraint!
    
    @IBOutlet private weak var loginLabelTopCC: NSLayoutConstraint!
    @IBOutlet private weak var loginLabelBottomCC: NSLayoutConstraint!
    
    //MARK: - Properties
    private var isKeyboardShown = false
    private var isRotatingWithKeyboard = false
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.image = UIImage(named: "icons8-customer-outlined")
        emailTextField.placeholder = "Felhasználónév"
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.activeLineColor = Constants.color
        
        passwordTextField.image = UIImage(named: "icons8-lock")
        passwordTextField.placeholder = "Jelszó"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.keyboardType = UIKeyboardType.alphabet
        passwordTextField.activeLineColor = Constants.color
        
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = Constants.color
        
        signUpTextView.delegate = self
        
        let attributedString = NSMutableAttributedString(string: signUpTextView.text)
        let range = attributedString.mutableString.range(of: "Regisztráljon!")
        attributedString.addAttribute(NSAttributedString.Key.link, value: "", range: range)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        signUpTextView.attributedText = attributedString
        signUpTextView.textAlignment = .center
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        signUpForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if isKeyboardShown { isRotatingWithKeyboard = true }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        var smallerBounds = loginLabel.bounds
        loginLabel.font = loginLabel.font.withSize(16)
        smallerBounds.size = loginLabel.intrinsicContentSize
        
        let scaleX = smallerBounds.size.width / loginLabel.frame.size.width
        let scaleY = smallerBounds.size.height / loginLabel.frame.size.height
        loginLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        loginLabel.bounds = smallerBounds
        
        logoImageViewTopCR.constant = 10
        logoImageViewHeightCR.constant = 48
        loginLabelTopCR.constant = 5
        loginLabelTopRC.constant = 30
        loginLabelBottomRC.constant = 10
        loginLabelTopCC.constant = 10
        loginLabelBottomCC.constant = 5
        UIView.animate(withDuration: 0.4) {
            self.loginLabel.transform = .identity
            self.view.layoutIfNeeded()
        }
        
        isKeyboardShown = true
        if isRotatingWithKeyboard { isRotatingWithKeyboard = false }
    }
    
    @objc private func keyboardDidShow(notification: Notification) {
        let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardCoverHeight = loginScrollView.frame.maxY - keyboardFrame.origin.y
        if keyboardCoverHeight > 0 { loginScrollViewHeight.constant -= keyboardCoverHeight }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        loginScrollViewHeight.constant = 163
        
        if isRotatingWithKeyboard { return }
        
        var biggerBounds = loginLabel.bounds
        loginLabel.font = loginLabel.font.withSize(32)
        biggerBounds.size = loginLabel.intrinsicContentSize
        
        let scaleX = biggerBounds.size.width / loginLabel.frame.size.width
        let scaleY = biggerBounds.size.height / loginLabel.frame.size.height
        loginLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        loginLabel.bounds = biggerBounds
        
        logoImageViewTopCR.constant = 50
        logoImageViewHeightCR.constant = 96
        loginLabelTopCR.constant = 20
        loginLabelTopRC.constant = 59
        loginLabelBottomRC.constant = 50
        loginLabelTopCC.constant = 39
        loginLabelBottomCC.constant = 30
        UIView.animate(withDuration: 0.4) {
            self.loginLabel.transform = .identity
            self.view.layoutIfNeeded()
        }
        
        isKeyboardShown = false
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SignUpViewController {
            vc.delegate = self
        }
    }
    
    //MARK: - Actions
    @IBAction func loginButtonTouchUpInside(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            DataCenter.shared.loginUser(email: email, password: password) { success, errorMessage in
                if success {
                    self.view.endEditing(true)
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.loginFailedLabel.text = errorMessage!
                    UIView.animate(withDuration: 0.2) {
                        self.loginFailedLabel.alpha = 1
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - Extension: UITextViewDelegate
extension LoginViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        NotificationCenter.default.removeObserver(self)
        performSegue(withIdentifier: "showSignUpSegue", sender: nil)
        return true
    }
}

//MARK: - Extension: SignUpViewControllerDelegate
extension LoginViewController: SignUpViewControllerDelegate {
    func signUpForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
