//
//  InformationViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2020. 01. 12..
//  Copyright © 2020. Daniel. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var topView: UIView!
    @IBOutlet private weak var topSeparatorView: UIView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    @IBOutlet private weak var titleLabelTop: NSLayoutConstraint!
    @IBOutlet private weak var contentLabelTop: NSLayoutConstraint!
    @IBOutlet private weak var bottomViewBottom: NSLayoutConstraint!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        topView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        bottomView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        topSeparatorView.alpha = 0
        titleLabel.alpha = 0
        contentLabel.alpha = 0
        titleLabelTop.constant = 130
        contentLabelTop.constant = 70
        bottomViewBottom.constant = -110
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { self.titleLabel.alpha = 1 })
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveEaseOut, animations: { self.contentLabel.alpha = 1 })
        
        titleLabelTop.constant = 100
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
        contentLabelTop.constant = 30
        UIView.animate(withDuration: 0.7, delay: 0.1, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
        bottomViewBottom.constant = 0
        UIView.animate(withDuration: 0.8, delay: 0.2, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
    }
    
    //MARK: - Actions
    @IBAction func cancelButtonTouchUpInside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func contactButtonTouchUpInside(_ sender: UIButton) {
        var urlString = ""
        switch sender.tag {
        case 0: urlString = "googlegmail://co?to=denhadnagy@freemail.hu"
        case 1: urlString = "mailto:denhadnagy@freemail.hu"
        case 2: urlString = "https://github.com/denhadnagy/KarbantartasNaplo"
        default: break
        }
        
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

//MARK: - Extension: UIScrollViewDelegate
extension InformationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        switch scrollView.contentOffset.y {
        case ..<20: topSeparatorView.alpha = 0
        case ..<30: topSeparatorView.alpha = 0.2 * ((scrollView.contentOffset.y - 20) / 10)
        case 30...: topSeparatorView.alpha = 0.2
        default: break
        }
    }
}
