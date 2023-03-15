//
//  TouchPadView.swift
//  HollySounds
//
//  Created by Ne Spesha on 10.04.22.
//

import Foundation
import AFKit
import UIKit
import RealmSwift

final class TouchPadView: AFDefaultView {
    
    /*
     MARK: -
     */
    
    var sound: Sound! {
        willSet {
            notificationToken?.invalidate()
        }
        didSet {
            notificationToken = sound.observe(keyPaths: [\Sound.state]) { [weak self] changes in
                switch changes {
                    case .change(_, _):
                        self?.animateUI()
                    case .deleted:
                        self?.notificationToken?.invalidate()
                    case .error(let error):
                        print(error)
                }
            }
            
            updateUI()
        }
    }
    
    /*
     MARK: -
     */
    
    private var notificationToken: NotificationToken?
    

    private var timeLabel: AFLabel!
    
    private var shapeLayer: CAShapeLayer!
    
    private var sampleHighlightedView: SampleAnimationView!
    private var loopHighlightedView: LoopAnimationView!
  
    var isPlayable: Bool = false
    var isFinishTutorial: Bool = false
    var didTapPlay: (() -> Void)?
    var timer: Timer?
    
    /*
     MARK: -
     */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /*
         */
        
        shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor(named: "Color 2")?.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineCap = .round
        shapeLayer.shadowColor = UIColor(named: "Color 2")?.cgColor
        shapeLayer.shadowOffset = .zero
        shapeLayer.shadowOpacity = 1
        layer.addSublayer(shapeLayer)
        
        /*
         */
        
        timeLabel = AFLabel()
        timeLabel.numberOfLines = 0
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        addSubview(timeLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        /*
         */
        
        sampleHighlightedView?.frame = bounds
        loopHighlightedView?.frame = bounds
        
        /*
         */
        
        shapeLayer.frame = bounds
        
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

        timeLabel.frame = bounds
    }
    
    private func updateUI() {
        
        /*
         */
        
        if sound.type == .single {
            sampleHighlightedView = SampleAnimationView()
            addSubview(sampleHighlightedView)
        } else {
            loopHighlightedView = LoopAnimationView()
            addSubview(loopHighlightedView)
        }
        
        /*
         */
        
        shapeLayer.lineDashPattern = sound.type.lineDashPattern
        
        shapeLayer.strokeColor = sound.type.color?.cgColor
        shapeLayer.shadowColor = isFinishTutorial ? UIColor(named: "Color 2")?.cgColor : UIColor.clear.cgColor
        
        sampleHighlightedView?.color = sound.type.color
        loopHighlightedView?.color = sound.type.color
      
      if !isFinishTutorial && isPlayable {
        fireTimer()
      }
    }
  
  func fireTimer() {
    timer?.invalidate()
    timer = nil
    timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
  }
  
  func stopTimer() {
    timer?.invalidate()
    timer = nil
    shapeLayer.strokeColor = sound.type.color?.cgColor
  }
    
    private func animateUI() {
        
        /*
         */

        if sound.type != .single {

            /*
             */
            
            UIView.animate(
                withDuration: FadeLength / 2,
                delay: 0,
                options: [
                    .beginFromCurrentState,
                    .allowUserInteraction,
                    .allowAnimatedContent
                ]
            ) {
                self.shapeLayer.lineWidth = self.sound.state == .playing ? 3 : 1
                self.shapeLayer.shadowRadius = self.sound.state == .playing ? 10 : 3
                self.loopHighlightedView?.innerView.alpha = self.sound.state == .playing ? 1 : 0
            } completion: { _ in
                
            }
            
            /*
             */
            
            if sound.state == .playing {
                loopHighlightedView?.play()
            } else {
                loopHighlightedView?.stop()
            }
            
//            /*
//             */
//
//            loopHighlightedView?.highlight()
            
        } else {
            if sound.state == .playing {
                
                /*
                 */
                
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
                scaleAnimation.duration = AnimationDurationSample
                scaleAnimation.fromValue = 1.1
                scaleAnimation.toValue = 1
                
                shapeLayer.add(
                    scaleAnimation,
                    forKey: "scaleAnimation"
                )
                
                let borderAnimation = CABasicAnimation(keyPath: "lineWidth")
                borderAnimation.duration = AnimationDurationSample
                borderAnimation.fromValue = 3
                borderAnimation.toValue = 1

                shapeLayer.add(
                    borderAnimation,
                    forKey: "borderAnimation"
                )
                
                let shadowRadiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
                shadowRadiusAnimation.duration = AnimationDurationSample
                shadowRadiusAnimation.fromValue = 10
                shadowRadiusAnimation.toValue = 3
                
                shapeLayer.add(
                    shadowRadiusAnimation,
                    forKey: "shadowRadiusAnimation"
                )
                
                /*
                 */
                
                sampleHighlightedView?.play()
            }
        }
    }
  
  @objc private func startTimer() {
    if shapeLayer.strokeColor == sound.type.color?.cgColor {
      UIView.animate(withDuration: 0.5, delay: 0) {
        self.shapeLayer.strokeColor = UIColor(named: "Color 7")?.cgColor
        self.shapeLayer.layoutIfNeeded()
      }
    } else {
      UIView.animate(withDuration: 0.5, delay: 0) {
        self.shapeLayer.strokeColor = self.sound.type.color?.cgColor
        self.shapeLayer.layoutIfNeeded()
      }
    }
  }
    
    /*
     MARK: -
     */
    
    override func touchesBegan(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesBegan(touches, with: event)

        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let location = touches.first?.location(in: self) ?? center
        
        var velocity = ((location.x - center.x) * (location.x - center.x) + (location.y - center.y) * (location.y - center.y)).squareRoot()
        velocity = 127 * (1 - velocity / (bounds.width * 1.5))
        
        
        if sound.type != .single {
            SoundManager.shared.isAutoplayEnabled = false
        }
        
      if isPlayable {
        let _ = self.layer.sublayers?.filter { $0.name == "DashBorder" }.map { $0.removeFromSuperlayer() }
        
        SoundManager.shared.play(sound: sound,velocity: UInt8(velocity))
        
        if !isFinishTutorial {
          didTapPlay?()
        }
      }
        
        /*
         */
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        /*
         */
        
      if isPlayable {
        loopHighlightedView?.highlight()
      }
    }
    
    override func touchesCancelled(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesCancelled(touches, with: event)
        
    }
    
    override func touchesEnded(
        _ touches: Set<UITouch>,
        with event: UIEvent?
    ) {
        super.touchesEnded(touches, with: event)

    }
}
