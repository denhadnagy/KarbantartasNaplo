//
//  ViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 10..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    //MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailGrayLineView: UIView!
    @IBOutlet weak var emailBlueLineView: UIView!
        
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordGrayLineView: UIView!
    @IBOutlet weak var passwordBlueLineView: UIView!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpTextView: UITextView!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        emailBlueLineView.frame.origin.x = emailGrayLineView.center.x
        emailBlueLineView.frame.size.width = 0
        
        passwordTextField.delegate = self
        passwordBlueLineView.frame.origin.x = passwordGrayLineView.center.x
        passwordBlueLineView.frame.size.width = 0
        
        loginButton.layer.cornerRadius = 5
        
        signUpTextView.delegate = self
        let attributedString = NSMutableAttributedString(string: signUpTextView.text)
        let range = attributedString.mutableString.range(of: "Sign up!")
        attributedString.addAttribute(NSAttributedStringKey.link, value: "", range: range)
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), range: range)
        attributedString.addAttribute(NSAttributedStringKey.underlineStyle, value: NSUnderlineStyle.styleSingle.rawValue, range: range)
        signUpTextView.attributedText = attributedString
        signUpTextView.textAlignment = .center
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(notification: Notification) {
        
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        
    }
    
    //MARK: - TextFieldDelegate functions
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            UIView.animate(withDuration: 0.4, animations: {
                self.emailBlueLineView.frame.origin.x = 0
                self.emailBlueLineView.frame.size.width = self.emailGrayLineView.frame.size.width
            })
        case 1:
            UIView.animate(withDuration: 0.4, animations: {
                self.passwordBlueLineView.frame.origin.x = 0
                self.passwordBlueLineView.frame.size.width = self.passwordGrayLineView.frame.size.width
            })
        default: break
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 0:
            UIView.animate(withDuration: 0.4, animations: {
                self.emailBlueLineView.frame.origin.x = self.emailGrayLineView.center.x
                self.emailBlueLineView.frame.size.width = 0
            })
        case 1:
            UIView.animate(withDuration: 0.4, animations: {
                self.passwordBlueLineView.frame.origin.x = self.passwordGrayLineView.center.x
                self.passwordBlueLineView.frame.size.width = 0
            })
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

