//
//  ViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 10..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextViewDelegate {
    //MARK: - Outlets
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var emailTextField: MyTextField!
    @IBOutlet weak var passwordTextField: MyTextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpTextView: UITextView!
    
    @IBOutlet weak var logoImageViewTopCR: NSLayoutConstraint!
    @IBOutlet weak var logoImageViewHeightCR: NSLayoutConstraint!
    @IBOutlet weak var loginLabelTopCR: NSLayoutConstraint!
    
    @IBOutlet weak var loginLabelTopRC: NSLayoutConstraint!
    @IBOutlet weak var loginLabelBottomRC: NSLayoutConstraint!
    
    @IBOutlet weak var loginLabelTopCC: NSLayoutConstraint!
    @IBOutlet weak var loginLabelBottomCC: NSLayoutConstraint!
    
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
        
        loginButton.layer.cornerRadius = 5
        loginButton.backgroundColor = Constants.color
        
        signUpTextView.delegate = self
        let attributedString = NSMutableAttributedString(string: signUpTextView.text)
        let range = attributedString.mutableString.range(of: "Sign up!")
        attributedString.addAttribute(NSAttributedStringKey.link, value: "", range: range)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), range: range)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        signUpTextView.attributedText = attributedString
        signUpTextView.textAlignment = .center
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
        var smallerBounds = loginLabel.bounds
        loginLabel.font = loginLabel.font.withSize(16)
        smallerBounds.size = loginLabel.intrinsicContentSize
        
        let scaleX = smallerBounds.size.width / loginLabel.frame.size.width
        let scaleY = smallerBounds.size.height / loginLabel.frame.size.height
        loginLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        loginLabel.bounds = smallerBounds
        
        UIView.animate(withDuration: 0.2, animations: {
            self.logoImageViewTopCR.constant = 10
            self.logoImageViewHeightCR.constant = 48
            self.loginLabelTopCR.constant = 5
            self.loginLabelTopRC.constant = 30
            self.loginLabelBottomRC.constant = 10
            self.loginLabelTopCC.constant = 10
            self.loginLabelBottomCC.constant = 5
            self.loginStackView.spacing = 10
            
            self.loginLabel.transform = .identity
            
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = true
        if isRotatingWithKeyboard { isRotatingWithKeyboard = false }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        if isRotatingWithKeyboard { return }
        
        var biggerBounds = loginLabel.bounds
        loginLabel.font = loginLabel.font.withSize(32)
        biggerBounds.size = loginLabel.intrinsicContentSize
        
        let scaleX = biggerBounds.size.width / loginLabel.frame.size.width
        let scaleY = biggerBounds.size.height / loginLabel.frame.size.height
        loginLabel.transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        loginLabel.bounds = biggerBounds
        
        UIView.animate(withDuration: 0.2, animations: {
            self.logoImageViewTopCR.constant = 50
            self.logoImageViewHeightCR.constant = 96
            self.loginLabelTopCR.constant = 20
            self.loginLabelTopRC.constant = 59
            self.loginLabelBottomRC.constant = 50
            self.loginLabelTopCC.constant = 39
            self.loginLabelBottomCC.constant = 30
            self.loginStackView.spacing = 20
            
            self.loginLabel.transform = .identity
            
            self.view.layoutIfNeeded()
        })
        
        isKeyboardShown = false
    }
    
    //MARK: - UITextViewDelegate functions
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let signUpViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUpViewController") as! SignUpViewController
        present(signUpViewController, animated: true, completion: nil)
        
        return true
    }
    
    //MARK: - Actions
    @IBAction func loginButtonTouchUpInside(_ sender: UIButton) {
        
    }
}
