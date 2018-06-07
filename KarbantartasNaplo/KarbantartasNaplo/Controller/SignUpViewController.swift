//
//  SignUpViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 21..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var signUpLabel: UILabel!
    @IBOutlet weak var signUpStackView: UIStackView!
    @IBOutlet weak var emailTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var passwordAgainTextField: MyTextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var logoImageViewTopCR: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewHeightCR: NSLayoutConstraint!
    @IBOutlet weak var signUpLabelTopCR: NSLayoutConstraint!
    
    @IBOutlet weak var signUpLabelTopRC: NSLayoutConstraint!
    @IBOutlet weak var signUpLabelBottomRC: NSLayoutConstraint!
    
    @IBOutlet weak var signUpLabelTopCC: NSLayoutConstraint!
    @IBOutlet weak var signUpLabelBottomCC: NSLayoutConstraint!
    
    var isKeyboardShown = false
    var isRotatingWithKeyboard = false

    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.image = UIImage(named: "icons8-new-post-100")
        emailTextField.placeholder = "Email"
        emailTextField.activeLineColor = Constants.color
        
        passwordTextField.image = UIImage(named: "icons8-lock-100")
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.activeLineColor = Constants.color
        
        passwordAgainTextField.image = UIImage(named: "icons8-lock-100")
        passwordAgainTextField.placeholder = "Password again"
        passwordAgainTextField.isSecureTextEntry = true
        passwordAgainTextField.activeLineColor = Constants.color
        
        signUpButton.layer.cornerRadius = 5
        signUpButton.backgroundColor = Constants.color
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if isKeyboardShown { isRotatingWithKeyboard = true }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        var smallerBounds = signUpLabel.bounds
        signUpLabel.font = signUpLabel.font.withSize(16)
        smallerBounds.size = signUpLabel.intrinsicContentSize
        
        let scaleX = smallerBounds.size.width / signUpLabel.frame.size.width
        let scaleY = smallerBounds.size.height / signUpLabel.frame.size.height
        signUpLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        signUpLabel.bounds = smallerBounds
        
        UIView.animate(withDuration: 0.2, animations: {
            self.logoImageViewTopCR.constant = 10
            self.logoImageViewHeightCR.constant = 48
            self.signUpLabelTopCR.constant = 5
            self.signUpLabelTopRC.constant = 30
            self.signUpLabelBottomRC.constant = 10
            self.signUpLabelTopCC.constant = 10
            self.signUpLabelBottomCC.constant = 5
            self.signUpStackView.spacing = 10
            
            self.signUpLabel.transform = .identity
            
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = true
        if isRotatingWithKeyboard { isRotatingWithKeyboard = false }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if isRotatingWithKeyboard { return }
        
        var biggerBounds = signUpLabel.bounds
        signUpLabel.font = signUpLabel.font.withSize(32)
        biggerBounds.size = signUpLabel.intrinsicContentSize
        
        let scaleX = biggerBounds.size.width / signUpLabel.frame.size.width
        let scaleY = biggerBounds.size.height / signUpLabel.frame.size.height
        signUpLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        signUpLabel.bounds = biggerBounds
        
        UIView.animate(withDuration: 0.2, animations: {
            self.logoImageViewTopCR.constant = 50
            self.logoImageViewHeightCR.constant = 96
            self.signUpLabelTopCR.constant = 20
            self.signUpLabelTopRC.constant = 59
            self.signUpLabelBottomRC.constant = 30
            self.signUpLabelTopCC.constant = 39
            self.signUpLabelBottomCC.constant = 20
            self.signUpStackView.spacing = 20
            
            self.signUpLabel.transform = .identity
            
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = false
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpButtonTouchUpInside(_ sender: UIButton) {
        
    }
}
