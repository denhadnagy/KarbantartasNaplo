//
//  DetailsViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 28..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

protocol DetailsViewControllerDelegate {
    func deviceChanged()
}

class DetailsViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private var serviceView: UIView!
    @IBOutlet private var setPeriodView: UIView!
    @IBOutlet private weak var setPeriodPickerView: UIPickerView!
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
    
    @IBOutlet private weak var errorViewBottom: NSLayoutConstraint!
    
    //MARK: - Properties
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
        setPeriodPickerView.dataSource = self
        setPeriodPickerView.delegate = self
        
        let lastServiceDate = Date(timeIntervalSince1970: TimeInterval(device.lastService))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        
        errorView.alpha = 0
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
        if errorViewBottom.constant == 0 { hideErrorView() }
        if view.subviews.contains(serviceView) { closePopupView(popupView: serviceView) }
        if view.subviews.contains(setPeriodView) { closePopupView(popupView: setPeriodView) }
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
        showPopupView(popupView: serviceView)
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
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                self.device.setOperationTimeToZero()
                
                let lastServiceDate = Date(timeIntervalSince1970: TimeInterval(self.device.lastService))
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy.MM.dd"
                
                DispatchQueue.main.async {
                    self.operationTimeLabel.text = self.device.operationTime != nil ? "\(self.device.operationTime!) h" : "?"
                    self.lastServiceLabel.text = dateFormatter.string(from: lastServiceDate)
                    self.rateProgressView.progressLineColor = self.device.severity.color
                    self.rateProgressView.value = self.device.rate ?? 0.0
                }
                self.delegateInDevicesViewController?.deviceChanged()
                
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
                                        errorMessage = ""
                                    }
                                }
                            }
                        } catch { }
                    }
                    
                    if errorMessage.isEmpty {
                        self.device.addNote(date: Date(timeIntervalSince1970: TimeInterval(self.device.lastService)), comment: comment)
                        self.delegateInNotesViewController?.deviceChanged()
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
        var periodDigits = device.period.digits
        for i in stride(from: setPeriodPickerView.numberOfComponents - 1, to: -1, by: -1) {
            let digit = periodDigits.popLast()
            setPeriodPickerView.selectRow(digit ?? 0, inComponent: i, animated: true)
        }
        
        showPopupView(popupView: setPeriodView)
    }
    
    @IBAction func setPeriodViewOkButtonTouchUpInside(_ sender: UIButton) {
        closePopupView(popupView: setPeriodView)
        
        let newPeriod = getPickerViewSelectedRowsAsInteger(pickerView: setPeriodPickerView)
        if newPeriod == device.period {
            if errorViewBottom.constant == 0 { hideErrorView() }
            return
        }
        else if newPeriod == 0 {
            showErrorView(withErrorMessage: "Periódus nem lehet 0!")
            return
        }
        
        NetworkManager.setDevicePeriod(device: device, period: newPeriod) { data, error in
            var errorMessage = "Kommunikációs hiba!"
            let oldPeriod = self.device.period
            
            if data != nil {
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                        if let message = jsonData["message"] as? String {
                            if message == "success" {
                                errorMessage = ""
                            }
                        }
                    }
                } catch { }
            }
            
            if errorMessage.isEmpty {
                self.device.setPeriod(to: newPeriod)
                
                DispatchQueue.main.async {
                    self.periodLabel.text = "\(self.device.period) h"
                    self.rateProgressView.progressLineColor = self.device.severity.color
                    self.rateProgressView.value = self.device.rate ?? 0.0
                }
                self.delegateInDevicesViewController?.deviceChanged()
                
                let comment = "Karbantartási periódus módosítása: \(oldPeriod) h -> \(self.device.period) h."
                let date = Date()
                NetworkManager.addNoteToDevice(device: self.device, creationDate: Int(date.timeIntervalSince1970), comment: comment) { data, error in
                    errorMessage = "Kommunikációs hiba!"
                    
                    if data != nil {
                        do {
                            if let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                if let message = jsonData["message"] as? String {
                                    if message == "success" {
                                        errorMessage = ""
                                    }
                                }
                            }
                        } catch { }
                    }
                    
                    if errorMessage.isEmpty {
                        self.device.addNote(date: date, comment: comment)
                        self.delegateInNotesViewController?.deviceChanged()
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
        errorView.text = withErrorMessage
        errorView.alpha = 1
        errorViewBottom.constant = 40
        UIView.animate(withDuration: 0.4) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showPopupView(popupView: UIView) {
        visualEffectView = UIVisualEffectView()
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(visualEffectView)
        visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffectView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        visualEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        view.addSubview(popupView)
        popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: 240).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.visualEffectView.effect = UIBlurEffect(style: .regular)
            popupView.transform = CGAffineTransform.identity
            popupView.alpha = 1
        }
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
    
    private func getPickerViewSelectedRowsAsInteger(pickerView: UIPickerView) -> Int {
        var selectedRowsString = ""
        for i in 0..<pickerView.numberOfComponents {
            selectedRowsString += String(pickerView.selectedRow(inComponent: i))
        }
        
        return Int(selectedRowsString) ?? 0
    }
}

//MARK: - Extensions: UIPickerView DataSource & Delegate
extension DetailsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 4
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
}

extension DetailsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(row)
    }
}

//MARK: - Extension: ErrorViewDelegate
extension DetailsViewController: ErrorViewDelegate {
    func hideErrorView() {
        errorViewBottom.constant = 0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
            self.errorView.alpha = 0
        }
    }
}