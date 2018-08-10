//
//  DetailsViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 28..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController, ErrorViewDelegate {
    //MARK: - Outlets
    @IBOutlet private var serviceView: UIView!
    @IBOutlet private weak var serviceContinueButton: UIButton!
    @IBOutlet private weak var detailsNavigationItem: UINavigationItem!
    @IBOutlet private weak var errorView: ErrorView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var tokenLabel: UILabel!
    @IBOutlet private weak var operationTimeLabel: UILabel!
    @IBOutlet private weak var periodLabel: UILabel!
    @IBOutlet private weak var lastServiceLabel: UILabel!
    @IBOutlet private weak var serviceButton: UIButton!
    @IBOutlet private weak var setPeriodButton: UIButton!
    @IBOutlet private weak var rateProgressView: CircleProgressView!
    
    @IBOutlet private weak var errorViewTop: NSLayoutConstraint!
    
    //MARK: - Properties
    private var serviceViewCenterY: NSLayoutConstraint!
    private var visualEffectView: UIVisualEffectView!
    var delegate: DetailsViewControllerDelegate?
    var device: Device!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceView.alpha = 0
        serviceView.layer.cornerRadius = 10
        serviceView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        serviceView.translatesAutoresizingMaskIntoConstraints = false
        serviceContinueButton.layer.cornerRadius = 5
        
        errorView.delegate = self
        
        let lastServiceDate = Date(timeIntervalSince1970: TimeInterval(device.lastService))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        nameLabel.text = device.name
        tokenLabel.text = device.token
        operationTimeLabel.text = device.operationTime != nil ? "\(device.operationTime!) h" : "?"
        rateProgressView.trackLineColor = Severity.undefined.color
        rateProgressView.progressLineColor = device.severity.color
        periodLabel.text = "\(device.period) h"
        lastServiceLabel.text = dateFormatter.string(from: lastServiceDate)
        serviceButton.layer.cornerRadius = 5
        serviceButton.backgroundColor = Constants.color
        setPeriodButton.layer.cornerRadius = 5
        setPeriodButton.backgroundColor = Constants.color
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rateProgressView.value = device.rate ?? 0.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if view.subviews.contains(serviceView) { closeServiceView() }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            if self.view.subviews.contains(self.serviceView) { self.setServiceViewPosition() }
        }, completion: nil)
    }
    
    //MARK: - Actions
    @IBAction func serviceButtonTouchUpInside(_ sender: UIButton) {
        visualEffectView = UIVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        NSLayoutConstraint(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        view.addSubview(serviceView)
        NSLayoutConstraint(item: serviceView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: serviceView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 240).isActive = true
        NSLayoutConstraint(item: serviceView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 160).isActive = true
        setServiceViewPosition()
        
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
            self.serviceView.transform = CGAffineTransform.identity
            self.serviceView.alpha = 1
        }
    }
    
    @IBAction func serviceViewContinueButtonTouchUpInside(_ sender: UIButton) {
        closeServiceView()
        NetworkManager.serviceDevice(device: device) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            
            if data != nil {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            if message == "success" {
                                self.device.setOperationTimeToZero()
                                
                                let lastServiceDate = Date(timeIntervalSince1970: TimeInterval(self.device.lastService))
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy.MM.dd"
                                
                                self.operationTimeLabel.text = self.device.operationTime != nil ? "\(self.device.operationTime!) h" : "?"
                                self.lastServiceLabel.text = dateFormatter.string(from: lastServiceDate)
                                self.rateProgressView.value = self.device.rate ?? 0.0
                                self.delegate?.deviceChanged()
                                
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage != "" {
                self.errorView.text = errorMessage
                UIView.animate(withDuration: 0.4) {
                    self.errorViewTop.constant = 0
                }
            } else {
                self.closeErrorView()
            }
        }
    }
    
    @IBAction func serviceViewCloseButtonTouchUpInside(_ sender: UIButton) {
        closeServiceView()
    }
    
    @IBAction func periodButtonTouchUpInside(_ sender: UIButton) {
        
    }
    
    //MARK: - Common functions
    private func setServiceViewPosition() {
        if serviceViewCenterY != nil {
            serviceViewCenterY.isActive = false
            serviceViewCenterY = nil
        }
        serviceViewCenterY = NSLayoutConstraint(item: serviceView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -view.frame.origin.y / 2)
        serviceViewCenterY.isActive = true
    }
    
    private func closeServiceView() {
        UIView.animate(withDuration: 0.2, animations: {
            self.serviceView.alpha = 0
            self.serviceView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.visualEffectView.effect = nil
        }) { completion in
            self.visualEffectView.removeFromSuperview()
            self.visualEffectView = nil
            self.serviceView.removeFromSuperview()
        }
    }
    
    //MARK: - ErrorViewDelegate function
    func closeErrorView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.errorViewTop.constant = -40
        }) { completion in
            self.errorView.text = ""
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
