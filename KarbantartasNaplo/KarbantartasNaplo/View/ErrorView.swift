//
//  ErrorView.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 08. 10..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

protocol ErrorViewDelegate {
    func showErrorView(withErrorMessage: String)
    func hideErrorView()
}

class ErrorView: UIView {
    @IBOutlet private var errorView: UIView!
    @IBOutlet private weak var errorDescriptionLabel: UILabel!
    var delegate: ErrorViewDelegate?
    
    var text = "" {
        didSet {
            errorDescriptionLabel.text = text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)
        addSubview(errorView)
        
        errorView.frame = bounds
        errorView.layer.cornerRadius = 10
        errorView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    @IBAction func closeButtonTouchUpInside(_ sender: UIButton) {
        delegate?.hideErrorView()
    }
}
