//
//  TutorialPadView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 20.02.2023.
//

import UIKit

final class TutorialPadView: UIView {

  private var shapeLayer: CAShapeLayer!
  private var sampleHighlightedView: SampleAnimationView!
  private var loopHighlightedView: LoopAnimationView!
  
  var tap:(() -> Void)?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    sampleHighlightedView?.frame = bounds
    loopHighlightedView?.frame = bounds
    shapeLayer.frame = bounds
    
    let rect = bounds.insetBy(dx: shapeLayer.lineWidth / 2,
                              dy: shapeLayer.lineWidth / 2)
    let radius = min(rect.width, rect.height) / 2
    let center = CGPoint(x: rect.midX,y: rect.midY)
    let path = UIBezierPath(arcCenter: center,
                            radius: radius,
                            startAngle: 0,
                            endAngle: .pi * 2,
                            clockwise: true)
    shapeLayer.path = path.cgPath
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    let generator = UIImpactFeedbackGenerator(style: .light)
    generator.impactOccurred()
    
    loopHighlightedView?.highlight()
    
    tap?()
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
      super.touchesCancelled(touches, with: event)
  }
  
  override func touchesEnded(
      _ touches: Set<UITouch>,
      with event: UIEvent?
  ) {
      super.touchesEnded(touches, with: event)

  }
}

private extension TutorialPadView {
  private func setupView() {
    shapeLayer = CAShapeLayer()
    shapeLayer.strokeColor = UIColor(named: "Color 2")?.cgColor
    shapeLayer.fillColor = UIColor.clear.cgColor
    shapeLayer.lineWidth = 1
    shapeLayer.lineCap = .round
    shapeLayer.shadowColor = UIColor(named: "Color 2")?.cgColor
    shapeLayer.shadowOffset = .zero
    shapeLayer.shadowOpacity = 1
    layer.addSublayer(shapeLayer)
  }
}
