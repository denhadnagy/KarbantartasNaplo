//
//  CircleProgressView.swift
//  KarbantartasNaplo
//
//  Created by Daniel on 2018. 06. 29..
//  Copyright © 2018. Daniel. All rights reserved.
//

import UICountingLabel
import UIKit

class CircleProgressView: UIView {
    //MARK: - Properties
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let valueLabel = UICountingLabel()
    
    var trackLineWidth = CGFloat(10.0) {
        didSet {
            trackLayer.lineWidth = trackLineWidth
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var progressLineWidth = CGFloat(10.0) {
        didSet {
            progressLayer.lineWidth = progressLineWidth
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var trackLineColor = UIColor.clear {
        didSet {
            trackLayer.strokeColor = trackLineColor.cgColor
        }
    }
    
    var progressLineColor = UIColor.clear {
        didSet {
            progressLayer.strokeColor = progressLineColor.cgColor
        }
    }
    
    var value = 0.0 {
        didSet {
            let fromValue = oldValue / 100.0
            let toValue = value / 100.0
            let duration = abs(fromValue - toValue)
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = fromValue
            animation.toValue = toValue
            animation.duration = duration
            
            progressLayer.strokeEnd = CGFloat(toValue)
            progressLayer.add(animation, forKey: "progress")
                        
            valueLabel.countFromCurrentValue(to: CGFloat(value), withDuration: duration)
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
        backgroundColor = UIColor.clear
        
        trackLayer.strokeColor = trackLineColor.cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = trackLineWidth
        trackLayer.lineCap = CAShapeLayerLineCap.round
        layer.addSublayer(trackLayer)
        
        progressLayer.strokeColor = progressLineColor.cgColor
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = progressLineWidth
        progressLayer.lineCap = CAShapeLayerLineCap.round
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
        
        valueLabel.font = UIFont.systemFont(ofSize: 17.0, weight: .thin)
        valueLabel.baselineAdjustment = .alignCenters
        valueLabel.textAlignment = .center
        valueLabel.format = "%.0f%%"
        addSubview(valueLabel)
    }
    
    //MARK: - Standard functions
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let radius = Double(min(frame.size.width, frame.size.height) - max(trackLineWidth, progressLineWidth)) / 2.0
        let bezierPath = UIBezierPath(arcCenter: center, radius: CGFloat(radius), startAngle: -CGFloat.pi * 0.5, endAngle: CGFloat.pi * 1.5, clockwise: true)
        trackLayer.path = bezierPath.cgPath
        progressLayer.path = bezierPath.cgPath
        
        valueLabel.frame = trackLayer.path!.boundingBox
        valueLabel.font = valueLabel.font.withSize(valueLabel.frame.size.height * 0.2)
    }
}
