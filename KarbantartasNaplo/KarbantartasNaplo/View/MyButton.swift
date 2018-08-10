//
//  MyButton.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 14..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class MyButton: UIButton {
    //MARK: - Properties
    var color: UIColor = UIColor.black {
        didSet {
            layer.borderColor = color.cgColor
            shapeLayer.fillColor = color.cgColor
        }
    }
    
    var isChecked = true {
        didSet {
            self.shapeLayer.opacity = self.isChecked ? 1 : 0
        }
    }
    
    private let shapeLayer = CAShapeLayer()
    
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
        backgroundColor = UIColor.clear
        layer.cornerRadius = 15
        layer.borderWidth = 2
        
        let bezierPath = UIBezierPath(ovalIn: bounds)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = color.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}
