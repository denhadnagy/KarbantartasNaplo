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
    @IBOutlet private var setPeriodView: UIView!
    @IBOutlet private weak var setPeriodLabel: UILabel!
    @IBOutlet private weak var setPeriodSlider: UISlider!
    @IBOutlet private weak var setPeriodOkButton: UIButton!
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
    private var popupViewCenterY: NSLayoutConstraint!
    private var visualEffectView: UIVisualEffectView!
    var delegateInDevicesViewController: DetailsViewControllerDelegate?
    var delegateInNotesViewController: DetailsViewControllerDelegate?
    var device: Device!
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceView.alpha = 0
        serviceView.layer.cornerRadius = 10
        serviceView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        serviceView.translatesAutoresizingMaskIntoConstraints = false
        
        setPeriodView.alpha = 0
        setPeriodView.layer.cornerRadius = 10
        setPeriodView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        setPeriodView.translatesAutoresizingMaskIntoConstraints = false
        
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
        serviceButton.isEnabled = device.operationTime != nil   //TODO:
        setPeriodButton.layer.cornerRadius = 5
        setPeriodButton.backgroundColor = Constants.color
        setPeriodButton.isEnabled = true    //TODO:
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        rateProgressView.value = device.rate ?? 0.0
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if errorViewTop.constant == 0 { hideErrorView() }
        if view.subviews.contains(serviceView) { closePopupView(popupView: serviceView) }
        if view.subviews.contains(setPeriodView) { closePopupView(popupView: setPeriodView) }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { context in
            if self.view.subviews.contains(self.serviceView) { self.setPopupViewPosition(forPopupView: self.serviceView) }
            if self.view.subviews.contains(self.setPeriodView) { self.setPopupViewPosition(forPopupView: self.setPeriodView) }
        }, completion: nil)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NotesViewController {
            delegateInNotesViewController = vc
            vc.device = device
        }
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
        setPopupViewPosition(forPopupView: serviceView)
        
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
            self.serviceView.transform = CGAffineTransform.identity
            self.serviceView.alpha = 1
        }
    }
    
    @IBAction func serviceViewContinueButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: serviceView)
        NetworkManager.serviceDevice(device: device) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            let oldOperationTime = self.device.operationTime
            
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
                                self.rateProgressView.progressLineColor = self.device.severity.color
                                self.rateProgressView.value = self.device.rate ?? 0.0
                                self.delegateInDevicesViewController?.deviceChanged()
                                
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                let comment = """
                Üzemidő nullázása.
                Előző karbantartás óta eltelt üzemidő: \(oldOperationTime != nil ? String(oldOperationTime!) : "?") h.
                Karbantartási periódus: \(self.device.period) h.
                """
                NetworkManager.addNoteToDevice(device: self.device, creationDate: self.device.lastService, comment: comment) { data, error in
                    errorMessage = "Kommunikációs hiba!"
                    
                    if data != nil {
                        do {
                            if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                if let message = jsonData["message"] as? String {
                                    if message == "success" {
                                        self.device.addNote(date: Date(timeIntervalSince1970: TimeInterval(self.device.lastService)), comment: comment)
                                        self.delegateInNotesViewController?.deviceChanged()
                                        
                                        errorMessage = ""
                                    }
                                }
                            }
                        } catch { }
                    }
                    
                    if errorMessage.isEmpty {
                        DispatchQueue.main.async { self.hideErrorView() }
                    } else {
                        DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
                    }
                }
            } else {
                DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
            }
        }
    }
    
    @IBAction func serviceViewCloseButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: serviceView)
    }
    
    @IBAction func periodButtonTouchUpInside(_ sender: UIButton) {
        visualEffectView = UIVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
        NSLayoutConstraint(item: visualEffectView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: visualEffectView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
        setPeriodLabel.text = "\(device.period) h"
        setPeriodSlider.value = Float(device.period)
        setPeriodOkButton.isEnabled = false
        view.addSubview(setPeriodView)
        NSLayoutConstraint(item: setPeriodView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: setPeriodView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 240).isActive = true
        NSLayoutConstraint(item: setPeriodView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 160).isActive = true
        setPopupViewPosition(forPopupView: setPeriodView)
        
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.effect = UIBlurEffect(style: .dark)
            self.setPeriodView.transform = CGAffineTransform.identity
            self.setPeriodView.alpha = 1
        }
    }
    
    @IBAction func setPeriodSliderValueChanged(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
        setPeriodLabel.text = "\(sliderValue) h"
        setPeriodOkButton.isEnabled = device.period != sliderValue
    }
    
    @IBAction func setPeriodViewOkButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: setPeriodView)
        NetworkManager.setDevicePeriod(device: device, period: Int(setPeriodSlider.value)) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            let oldPeriod = self.device.period
            
            if data != nil {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            if message == "success" {
                                self.device.setPeriod(period: Int(self.setPeriodSlider.value))
                                
                                self.periodLabel.text = "\(self.device.period) h"
                                self.rateProgressView.progressLineColor = self.device.severity.color
                                self.rateProgressView.value = self.device.rate ?? 0.0
                                self.delegateInDevicesViewController?.deviceChanged()
                                
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                let comment = "Karbantartási periódus módosítása: \(oldPeriod) h -> \(self.device.period) h."
                let date = Date()
                NetworkManager.addNoteToDevice(device: self.device, creationDate: Int(date.timeIntervalSince1970), comment: comment) { data, error in
                    errorMessage = "Kommunikációs hiba!"
                    
                    if data != nil {
                        do {
                            if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                if let message = jsonData["message"] as? String {
                                    if message == "success" {
                                        self.device.addNote(date: date, comment: comment)
                                        self.delegateInNotesViewController?.deviceChanged()
                                        
                                        errorMessage = ""
                                    }
                                }
                            }
                        } catch { }
                    }
                    
                    if errorMessage.isEmpty {
                        DispatchQueue.main.async { self.hideErrorView() }
                    } else {
                        DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
                    }
                }
            } else {
                DispatchQueue.main.async { self.showErrorView(withErrorMessage: errorMessage) }
            }
        }
    }
    
    @IBAction func setPeriodViewCloseButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: setPeriodView)
    }
    
    //MARK: - Common functions
    private func showErrorView(withErrorMessage: String) {
        self.errorView.text = withErrorMessage
        self.errorViewTop.constant = 0
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setPopupViewPosition(forPopupView: UIView) {
        if popupViewCenterY != nil {
            popupViewCenterY.isActive = false
            popupViewCenterY = nil
        }
        popupViewCenterY = NSLayoutConstraint(item: forPopupView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -view.frame.origin.y / 2)
        popupViewCenterY.isActive = true
    }
    
    private func closePopupView(popupView: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            popupView.alpha = 0
            popupView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.visualEffectView.effect = nil
        }) { completion in
            self.visualEffectView.removeFromSuperview()
            self.visualEffectView = nil
            popupView.removeFromSuperview()
        }
    }
    
    //MARK: - ErrorViewDelegate function
    func hideErrorView() {
        self.errorViewTop.constant = -40
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
        }
    }
}
