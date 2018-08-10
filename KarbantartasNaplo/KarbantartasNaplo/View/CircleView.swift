//
//  CircleView.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 12..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UIKit

class CircleView: UIView {
    private let shapeLayer = CAShapeLayer()
    
    var color = Severity.undefined.color {
        didSet {
            shapeLayer.fillColor = color.cgColor
        }
    }
    
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
        
        let bezierPath = UIBezierPath(ovalIn: bounds)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.fillColor = color.cgColor
        
        layer.addSublayer(shapeLayer)
    }
}
