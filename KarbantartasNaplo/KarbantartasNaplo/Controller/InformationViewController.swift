//
//  InformationViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2020. 01. 12..
//  Copyright © 2020. Daniel. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    @IBOutlet private weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet private weak var contentLabelTop: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        topView.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        titleLabel.alpha = 0
        contentLabel.alpha = 0
        titleLabelTop.constant = 130
        contentLabelTop.constant = 70
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { self.titleLabel.alpha = 1 })
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: { self.contentLabel.alpha = 1 })
        
        titleLabelTop.constant = 100
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
        contentLabelTop.constant = 30
        UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
    }
    
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
