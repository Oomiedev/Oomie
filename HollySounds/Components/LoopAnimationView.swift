//
//  DashedRoundedView.swift
//  HollySounds
//
//  Created by Ne Spesha on 8.08.22.
//

import Foundation
import UIKit

final class LoopAnimationView: UIView {

    /*
     MARK: -
     */
    
    var color: UIColor?
    
    /*
     MARK: -
     */
    
    private var innerDelegate = SampleAnimationViewDelegate()
    private var outerDelegate = SampleAnimationViewDelegate()
    
    var innerView: UIView = {
        let view = UIView()
        view.alpha = 0
        return view
    }()
    
    /*
     MARK: -
     */
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(innerView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        innerView.frame = bounds
    }
    
    /*
     MARK: -
     */
    
    func play() {
        createNextCircle()
    }
    
    func stop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func highlight() {
        createNextOuterCircle()
    }
    
    @objc
    private func createNextCircle() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = color?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.frame = bounds
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = UIScreen.main.scale
        innerView.layer.addSublayer(shapeLayer)
        
        let rect = innerView.bounds.insetBy(
            dx: shapeLayer.lineWidth / 2,
            dy: shapeLayer.lineWidth / 2
        )
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        shapeLayer.path = path.cgPath
        
        /*
         */
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = AnimationDurationLoop
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 0
        scaleAnimation.delegate = innerDelegate
        
        shapeLayer.add(
            scaleAnimation,
            forKey: "scaleAnimation"
        )
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi * 2)
        rotationAnimation.duration = AnimationDurationLoop
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        shapeLayer.add(
            rotationAnimation,
            forKey: "rotationAnimation"
        )
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = AnimationDurationLoop
        shapeLayer.add(
            opacityAnimation,
            forKey: "opacityAnimation"
        )
        
        /*
         */
        
        shapeLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
        
        innerDelegate.stack.append(shapeLayer)
        
        /*
         */
        
        perform(
            #selector(createNextCircle),
            with: nil,
            afterDelay: 0.5
        )
    }
    
    private func createNextOuterCircle() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(named: "Color 2")?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineCap = .round
        shapeLayer.lineDashPattern = [3, 3]
        shapeLayer.frame = bounds
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = UIScreen.main.scale
        layer.addSublayer(shapeLayer)
        
        let rect = bounds.insetBy(
            dx: shapeLayer.lineWidth / 2,
            dy: shapeLayer.lineWidth / 2
        )
        let radius = min(rect.width, rect.height) / 2
        let center = CGPoint(
            x: rect.midX,
            y: rect.midY
        )
        let path = UIBezierPath(
            arcCenter: center,
            radius: radius,
            startAngle: 0,
            endAngle: .pi * 2,
            clockwise: true
        )
        shapeLayer.path = path.cgPath
        
        /*
         */
        
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.duration = AnimationDurationSample
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 2
        scaleAnimation.delegate = outerDelegate
        
        shapeLayer.add(
            scaleAnimation,
            forKey: "scaleAnimation"
        )
        
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: -Double.pi * 2)
        rotationAnimation.duration = AnimationDurationSample
        rotationAnimation.isCumulative = true
        rotationAnimation.repeatCount = Float.greatestFiniteMagnitude
        shapeLayer.add(
            rotationAnimation,
            forKey: "rotationAnimation"
        )
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.duration = AnimationDurationSample
        shapeLayer.add(
            opacityAnimation,
            forKey: "opacityAnimation"
        )
        
        /*
         */
        
        shapeLayer.opacity = 0
        shapeLayer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
        
        outerDelegate.stack.append(shapeLayer)
    }
}
