//
//  DevicesViewController.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 11..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class DevicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, DetailsViewControllerDelegate, ErrorViewDelegate {
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
    
    @IBOutlet private weak var errorViewTop: NSLayoutConstraint!
    
    //MARK: - Properties
    private var displayedDevices = [Device]()
    private var selectedDevice: Device?
    
    //MARK: - Standard functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Remove border of navigation bar.
        let image = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.shadowImage = image
        navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        
        filterView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        filterView.layer.borderWidth = 1
        urgentFilterButton.color = Severity.urgent.color
        urgentFilterLabel.text = Severity.urgent.rawValue
        actualFilterButton.color = Severity.actual.color
        actualFilterLabel.text = Severity.actual.rawValue
        soonFilterButton.color = Severity.soon.color
        soonFilterLabel.text = Severity.soon.rawValue
        okFilterButton.color = Severity.ok.color
        okFilterLabel.text = Severity.ok.rawValue
        
        errorView.delegate = self
        
        devicesTableView.dataSource = self
        devicesTableView.delegate = self

        DataCenter.shared.getDevices() { success in
            if success {
                self.displayedDevices = DataCenter.shared.devices
                self.devicesTableView.reloadData()
                self.closeErrorView()
            } else {
                self.errorView.text = "Kommunikációs hiba!"
                UIView.animate(withDuration: 0.4) {
                    self.errorViewTop.constant = 0
                }
            }
        }
    }

    //MARK: - UITableViewDataSource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedDevices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = devicesTableView.dequeueReusableCell(withIdentifier: "devicesTableViewCell") as! DevicesTableViewCell
        cell.device = displayedDevices[indexPath.row]
        return cell
    }
    
    //MARK: - UITableViewDelegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedDevice = displayedDevices[indexPath.row]
        performSegue(withIdentifier: "showDetailsSegue", sender: nil)
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailsViewController {
            vc.delegate = self
            vc.device = selectedDevice
        }
    }
    
    //MARK: - Actions
    @IBAction func filterButtonTouchUpInside(_ sender: MyButton) {
        sender.isChecked = !sender.isChecked
        filterDevices()
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
    
    //MARK: - DetailsViewControllerDelegate function
    func deviceChanged() {
        filterDevices()
    }
    
    //MARK: - ErrorViewDelegate function
    func closeErrorView() {
        UIView.animate(withDuration: 0.4, animations: {
            self.errorViewTop.constant = -40
        }) { completion in
            self.errorView.text = ""
        }
    }
}
