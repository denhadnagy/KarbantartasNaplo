//
//  DevicesViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 11..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit
//import Firebase

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
    
    @IBOutlet private weak var errorViewLeading: NSLayoutConstraint!
    @IBOutlet private weak var errorViewWidth: NSLayoutConstraint!
    @IBOutlet private weak var loginButtonCenterX: NSLayoutConstraint!
    @IBOutlet private weak var aboutButtonCenterX: NSLayoutConstraint!
    
    //MARK: - Properties
    private let refreshControl = UIRefreshControl()
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
                })
                
                loginButtonCenterX.constant = -loginButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
            } else {
                aboutButtonCenterX.constant = -aboutButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: {
                    self.menuButton.setImage(UIImage(named: "icons8-menu"), for: .normal)
                    self.menuButton.transform = CGAffineTransform.identity
                    self.view.layoutIfNeeded()
                })
                
                loginButtonCenterX.constant = -loginButtonCenterX.constant
                UIView.animate(withDuration: duration, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
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
        
        refreshControl.tintColor = Constants.color
        refreshControl.addTarget(self, action: #selector(getDevices), for: .valueChanged)
        devicesTableView.refreshControl = refreshControl
        
        getDevices()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        errorViewWidth.constant = UIScreen.main.bounds.width - 40
        if errorViewLeading.constant != 0 { errorViewLeading.constant = -UIScreen.main.bounds.width + 20 }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMenuShown { isMenuShown = false }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if errorViewLeading.constant != 0 { hideErrorView() }
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
        case 1: performSegue(withIdentifier: "showInformationSegue", sender: nil)
        case 2: performSegue(withIdentifier: "showLoginSegue", sender: nil)
        default: break
        }

        isMenuShown = !isMenuShown
        
//        let db = Firestore.firestore()
//        for device in DataCenter.shared.devices {
//            var notesData = [[String: Any]]()
//            for note in device.notes {
//                let noteData: [String : Any] = [
//                    "creationDate": note.creationDate,
//                    "comment": note.comment
//                ]
//                notesData.append(noteData)
//            }
//            let deviceData: [String : Any] = [
//                "number": device.number,
//                "id": device.id,
//                "token": device.token,
//                "name": device.name,
//                "itemNo": device.itemNo ?? "null",
//                "operationTime": device.operationTime ?? "null",
//                "period": device.period,
//                "lastService": device.lastService,
//                "notes": notesData
//            ]
//            db.collection("devices").document(String(device.id)).setData(deviceData) { error in
//                if let e = error {
//                    print("Error writing document: \(e)")
//                } else {
//                    print("Document successfully written!")
//                }
//            }
//        }
        
//        for device in DataCenter.shared.devices {
//            let deviceData: [String : Any] = [
//                "number": device.number,
//                "id": device.id,
//                "token": device.token,
//                "name": device.name,
//                "itemNo": device.itemNo ?? "null",
//                "operationTime": device.operationTime ?? "null",
//                "period": device.period,
//                "lastService": device.lastService
//            ]
//            db.collection("devices").document(String(device.id)).setData(deviceData) { error in
//                if let e = error {
//                    print("Error writing device: \(e)")
//                } else {
//                    print("Device successfully written!")
//                }
//            }
//        }
    }
    
    //MARK: - Common functions
    private func filterDevices() {
        displayedDevices = DataCenter.shared.devices.filter() { device in
            var isShowing = false
            
            switch device.severity {
            case .urgent: isShowing = urgentFilterButton.isChecked
            case .actual: isShowing = actualFilterButton.isChecked
            case .soon: isShowing = soonFilterButton.isChecked
            case .ok: isShowing = okFilterButton.isChecked
            case .undefined: isShowing = true
            }
            
            return isShowing
        }
        devicesTableView.reloadData()
    }
    
    @objc private func getDevices() {
        DataCenter.shared.getDevices() { success in
            if success {
                DispatchQueue.main.async {
                    self.filterDevices()
                    self.hideErrorView()
                }
            } else {
                DispatchQueue.main.async {
                    self.showErrorView(withErrorMessage: "Kommunikációs hiba!")
                }
            }
            self.refreshControl.endRefreshing()
        }
    }
}

//MARK: - Extensions: UITableView DataSource & Delegate
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

//MARK: - Extension: DetailsViewControllerDelegate
extension DevicesViewController: DetailsViewControllerDelegate {
    func deviceChanged() {
        filterDevices()
    }
}

//MARK: - Extension: ErrorViewDelegate
extension DevicesViewController: ErrorViewDelegate {
    func showErrorView(withErrorMessage: String) {
        errorView.text = withErrorMessage
        errorViewLeading.constant = -UIScreen.main.bounds.width + 20
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: { self.view.layoutIfNeeded() })
    }
    
    func hideErrorView() {
        errorViewLeading.constant = 0
        UIView.animate(withDuration: 0.1, animations: {
            self.view.layoutIfNeeded()
        }) { completion in
            self.errorView.text = ""
        }
    }
}
