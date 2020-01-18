//
//  SeverityView.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 21..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class SeverityView: UIView {
    //MARK: - Outlets
    @IBOutlet private var severityView: UIView!
    @IBOutlet private weak var severityLabel: UILabel!
    @IBOutlet private weak var deviceCountLabel: UILabel!
    @IBOutlet private weak var deviceLabel: UILabel!
    
    //MARK: - Properties
    var severity = Severity.undefined {
        didSet {
            severityView.backgroundColor = severity.color
            severityLabel.text = severity.rawValue
        }
    }
    
    var textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) {
        didSet {
            severityLabel.textColor = textColor
            deviceCountLabel.textColor = textColor
            deviceLabel.textColor = textColor
        }
    }
    
    var deviceCount = 0 {
        didSet {
            deviceCountLabel.text = String(deviceCount)
        }
    }
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("SeverityView", owner: self, options: nil)
        addSubview(severityView)
        
        layer.cornerRadius = 10
        severityView.layer.cornerRadius = 10
        severityView.frame = bounds
        severityView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        layoutIfNeeded()
    }
    
    //MARK: - Standard functions
    override func layoutSubviews() {
        super.layoutSubviews()
        deviceCountLabel.font = deviceCountLabel.font.withSize(deviceCountLabel.frame.size.height * 0.8)
    }
}
