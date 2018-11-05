//
//  DevicesViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 11..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class DevicesViewController: UIViewController {
    //MARK: - Outlets
    @IBOutlet private weak var filterView: UIView!
    @IBOutlet private weak var urgentFilterButton: MyButton!
    @IBOutlet private weak var actualFilterButton: MyButton!
    @IBOutlet private weak var soonFilterButton: MyButton!
    @IBOutlet private weak var okFilterButton: MyButton!
    @IBOutlet private weak var urgentFilterLabel: UILabel!
    @IBOutlet private weak var actualFilterLabel: UILabel!
    @IBOutlet private weak var soonFilterLabel: UILabel!
    @IBOutlet private weak var okFilterLabel: UILabel!
    @IBOutlet private weak var errorView: ErrorView!
    @IBOutlet private weak var devicesTableView: UITableView!
    @IBOutlet private weak var menuButton: MyFloatingButton!
    
    @IBOutlet private weak var errorViewBottom: NSLayoutConstraint!
    @IBOutlet private weak var loginButtonCenterX: NSLayoutConstraint!
    @IBOutlet private weak var aboutButtonCenterX: NSLayoutConstraint!
    
    //MARK: - Properties
    private var displayedDevices = [Device]()
    private var selectedDevice: Device?
    
    private var isMenuShown = false {
        didSet {
            let duration = 0.4
            let damping = CGFloat(0.4)
            let velocity = CGFloat(0.1)
            if isMenuShown {
                aboutButtonCenterX.constant = -aboutButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: {
                    self.menuButton.setImage(UIImage(named: "icons8-multiply"), for: .normal)
                    self.menuButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                loginButtonCenterX.constant = -loginButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() }, completion: nil)
            } else {
                aboutButtonCenterX.constant = -aboutButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: {
                    self.menuButton.setImage(UIImage(named: "icons8-menu"), for: .normal)
                    self.menuButton.transform = CGAffineTransform.identity
                    self.view.layoutIfNeeded()
                }, completion: nil)
                
                loginButtonCenterX.constant = -loginButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() }, completion: nil)
            }
        }
    }
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        errorView.delegate = self
        devicesTableView.dataSource = self
        devicesTableView.delegate = self
        
        errorView.alpha = 0
        urgentFilterButton.color = Severity.urgent.color
        urgentFilterLabel.text = Severity.urgent.rawValue
        actualFilterButton.color = Severity.actual.color
        actualFilterLabel.text = Severity.actual.rawValue
        soonFilterButton.color = Severity.soon.color
        soonFilterLabel.text = Severity.soon.rawValue
        okFilterButton.color = Severity.ok.color
        okFilterLabel.text = Severity.ok.rawValue
        loginButtonCenterX.constant = -loginButtonCenterX.constant
        aboutButtonCenterX.constant = -aboutButtonCenterX.constant
        
//        DataCenter.shared.getDevices() { success in
//            if success {
//                DispatchQueue.main.async {
//                    self.displayedDevices = DataCenter.shared.devices
//                    self.devicesTableView.reloadData()
//                    self.hideErrorView()
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.errorView.text = "Kommunikációs hiba!"
//                    self.errorViewBottom.constant = 40
//                    UIView.animate(withDuration: 0.4) {
//                        self.view.layoutIfNeeded()
//                    }
//                }
//            }
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMenuShown { isMenuShown = false }
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsViewController {
            vc.delegateInDevicesViewController = self
            vc.device = selectedDevice
        }
    }
    
    //MARK: - Actions
    @IBAction func filterButtonTouchUpInside(_ sender: MyButton) {
        sender.isChecked = !sender.isChecked
        filterDevices()
    }
    
    @IBAction func menuButtonTouchUpInside(_ sender: MyFloatingButton) {
        switch sender.tag {
        case 1: debugPrint("About")
        case 2: performSegue(withIdentifier: "showLoginSegue", sender: nil)
        default:
            break
        }
        
        isMenuShown = !isMenuShown
    }
    
    //MARK: - Common functions
    private func filterDevices() {
        displayedDevices = DataCenter.shared.devices.filter() { device in
            var filterButton: MyButton
            
            let severity = device.severity
            switch severity {
            case .urgent: filterButton = urgentFilterButton
            case .actual: filterButton = actualFilterButton
            case .soon: filterButton = soonFilterButton
            case .ok: filterButton = okFilterButton
            case .undefined: filterButton = MyButton()
            }
            
            if filterButton.isChecked {
                return true
            } else {
                return false
            }
        }
        devicesTableView.reloadData()
    }
}

//MARK: - Extensions
extension DevicesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = devicesTableView.dequeueReusableCell(withIdentifier: "devicesTableViewCell") as! DevicesTableViewCell
        cell.device = displayedDevices[indexPath.row]
        return cell
    }
}

extension DevicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDevice = displayedDevices[indexPath.row]
        performSegue(withIdentifier: "showDetailsSegue", sender: nil)
    }
}

extension DevicesViewController: DetailsViewControllerDelegate {
    func deviceChanged() {
        filterDevices()
    }
}

extension DevicesViewController: ErrorViewDelegate {
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
