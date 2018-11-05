//
//  SignUpViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 21..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var signUpLabel: UILabel!
    @IBOutlet private weak var emailTextField: MyTextField!
    @IBOutlet private weak var passwordTextField: MyTextField!
    @IBOutlet private weak var passwordAgainTextField: MyTextField!
    @IBOutlet private weak var signUpFailedLabel: UILabel!
    @IBOutlet private weak var signUpButton: UIButton!
    
    @IBOutlet private weak var logoImageViewTopCR: NSLayoutConstraint!
    @IBOutlet private weak var logoImageViewHeightCR: NSLayoutConstraint!
    @IBOutlet private weak var signUpLabelTopCR: NSLayoutConstraint!
    
    @IBOutlet private weak var signUpLabelTopRC: NSLayoutConstraint!
    @IBOutlet private weak var signUpLabelBottomRC: NSLayoutConstraint!
    
    @IBOutlet private weak var signUpLabelTopCC: NSLayoutConstraint!
    @IBOutlet private weak var signUpLabelBottomCC: NSLayoutConstraint!
    
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
        
        passwordAgainTextField.image = UIImage(named: "icons8-lock")
        passwordAgainTextField.placeholder = "Jelszó újra"
        passwordAgainTextField.isSecureTextEntry = true
        passwordAgainTextField.keyboardType = UIKeyboardType.alphabet
        passwordAgainTextField.activeLineColor = Constants.color
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.backgroundColor = Constants.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if isKeyboardShown { isRotatingWithKeyboard = true }
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        var smallerBounds = signUpLabel.bounds
        signUpLabel.font = signUpLabel.font.withSize(16)
        smallerBounds.size = signUpLabel.intrinsicContentSize
        
        let scaleX = smallerBounds.size.width / signUpLabel.frame.size.width
        let scaleY = smallerBounds.size.height / signUpLabel.frame.size.height
        signUpLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        signUpLabel.bounds = smallerBounds
        
        logoImageViewTopCR.constant = 10
        logoImageViewHeightCR.constant = 48
        signUpLabelTopCR.constant = 5
        signUpLabelTopRC.constant = 30
        signUpLabelBottomRC.constant = 10
        signUpLabelTopCC.constant = 10
        signUpLabelBottomCC.constant = 5
        UIView.animate(withDuration: 0.2, animations: {
            self.signUpLabel.transform = .identity
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = true
        if isRotatingWithKeyboard { isRotatingWithKeyboard = false }
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        if isRotatingWithKeyboard { return }
        
        var biggerBounds = signUpLabel.bounds
        signUpLabel.font = signUpLabel.font.withSize(32)
        biggerBounds.size = signUpLabel.intrinsicContentSize
        
        let scaleX = biggerBounds.size.width / signUpLabel.frame.size.width
        let scaleY = biggerBounds.size.height / signUpLabel.frame.size.height
        signUpLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        signUpLabel.bounds = biggerBounds
        
        logoImageViewTopCR.constant = 50
        logoImageViewHeightCR.constant = 96
        signUpLabelTopCR.constant = 20
        signUpLabelTopRC.constant = 59
        signUpLabelBottomRC.constant = 30
        signUpLabelTopCC.constant = 39
        signUpLabelBottomCC.constant = 20
        UIView.animate(withDuration: 0.2, animations: {
            self.signUpLabel.transform = .identity
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = false
    }
    
    //MARK: - Actions
    @IBAction func signUpButtonTouchUpInside(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, let passwordAgain = passwordAgainTextField.text {
            DataCenter.shared.signUpUser(email: email, password: password, passwordAgain: passwordAgain) { success, errorMessage in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.signUpFailedLabel.text = errorMessage!
                    UIView.animate(withDuration: 0.2) {
                        self.signUpFailedLabel.alpha = 1
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
