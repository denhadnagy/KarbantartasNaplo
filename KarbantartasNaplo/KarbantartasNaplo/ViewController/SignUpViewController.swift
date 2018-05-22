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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailGrayLineView: UIView!
    @IBOutlet weak var emailBlueLineView: UIView!
    
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordGrayLineView: UIView!
    @IBOutlet weak var passwordBlueLineView: UIView!
    
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var passwordAgainGrayLineView: UIView!
    @IBOutlet weak var passwordAgainBlueLineView: UIView!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        emailBlueLineView.frame.origin.x = emailGrayLineView.center.x
        emailBlueLineView.frame.size.width = 0
        
        passwordTextField.delegate = self
        passwordBlueLineView.frame.origin.x = passwordGrayLineView.center.x
        passwordBlueLineView.frame.size.width = 0
        
        passwordAgainTextField.delegate = self
        passwordAgainBlueLineView.frame.origin.x = passwordAgainGrayLineView.center.x
        passwordAgainBlueLineView.frame.size.width = 0
        
        signUpButton.layer.cornerRadius = 5
        
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
        case 2:
            UIView.animate(withDuration: 0.4, animations: {
                self.passwordAgainBlueLineView.frame.origin.x = 0
                self.passwordAgainBlueLineView.frame.size.width = self.passwordAgainGrayLineView.frame.size.width
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
        case 2:
            UIView.animate(withDuration: 0.4, animations: {
                self.passwordAgainBlueLineView.frame.origin.x = self.passwordAgainGrayLineView.center.x
                self.passwordAgainBlueLineView.frame.size.width = 0
            })
        default: break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpButtonTouchUpInside(_ sender: UIButton) {
        
    }
}
