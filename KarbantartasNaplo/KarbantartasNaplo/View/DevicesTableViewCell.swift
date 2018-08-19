//
//  DevicesTableViewCell.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 12..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class DevicesTableViewCell: UITableViewCell {
    @IBOutlet private weak var circleView: CircleView!
    @IBOutlet private weak var tokenNameLabel: UILabel!
    @IBOutlet private weak var lastServiceLabel: UILabel!
    @IBOutlet private weak var operationTimeLabel: UILabel!
    @IBOutlet private weak var rateLabel: UILabel!
    
    var device: Device! {
        didSet {
            let lastServiceDate = Date(timeIntervalSince1970: TimeInterval(device.lastService))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy.MM.dd"
            
            circleView.color = device.severity.color
            tokenNameLabel.text = "\(device.token)   \(device.name)"
            lastServiceLabel.text = "Előző szerviz: \(dateFormatter.string(from: lastServiceDate))"
            operationTimeLabel.text = "Üzemidő: \(device.operationTime != nil ? String(device.operationTime!) : "?")/\(device.period) h"
            rateLabel.text = device.rate != nil ? "\(String(format: "%.0f", device.rate!)) %" : "0 %"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
