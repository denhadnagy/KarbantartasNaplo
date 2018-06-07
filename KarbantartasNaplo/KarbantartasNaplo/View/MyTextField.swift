//
//  MyTextField.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 05. 28..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class MyTextField: UIView, UITextFieldDelegate {
    //MARK: - Outlets
    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var inactiveLineView: UIView!
    @IBOutlet private weak var activeLineView: UIView!
    
    //MARK: - Properties
    var image: UIImage! {
        didSet { imageView.image = image }
    }
    
    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    var isSecureTextEntry = false {
        didSet {
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    var activeLineColor: UIColor! {
        didSet {
            activeLineView.backgroundColor = activeLineColor
        }
    }
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("MyTextField", owner: self, options: nil)
        stackView.frame = self.bounds
        stackView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(stackView)
        
        textField.delegate = self
        
        activeLineView.frame.origin.x = inactiveLineView.center.x
        activeLineView.frame.size.width = 0
    }
    
    override func layoutSubviews() {
        if activeLineView.frame.size.width > 0 { activeLineView.frame.size.width = frame.size.width }
    }
    
    //MARK: - TextFieldDelegates
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        UIView.animate(withDuration: 0.4, animations: {
            self.activeLineView.frame.origin.x = 0
            self.activeLineView.frame.size.width = self.inactiveLineView.frame.size.width
        })
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.4, animations: {
            self.activeLineView.frame.origin.x = self.inactiveLineView.center.x
            self.activeLineView.frame.size.width = 0
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
