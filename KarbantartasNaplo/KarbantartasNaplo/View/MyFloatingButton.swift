//
//  MyFloatingButton.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 10. 28..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class MyFloatingButton: UIButton {
    //MARK: - Properties
    private let overlayView = UIView()
    
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
        layer.cornerRadius = bounds.width / 2
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.8
        layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        overlayView.frame = bounds
        overlayView.layer.cornerRadius = layer.cornerRadius
        overlayView.backgroundColor = UIColor.clear
        overlayView.isUserInteractionEnabled = false
        addSubview(overlayView)
    }
    
    //MARK: - Standard functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        overlayView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1993525257)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        overlayView.backgroundColor = UIColor.clear
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        overlayView.backgroundColor = UIColor.clear
    }
}
