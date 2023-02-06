//
//  PackageCell.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import Foundation
import AFKit
import UIKit
import RealmSwift
import SDWebImage

final class PackageCell: AFDefaultCollectionViewCell {
    
    /*
     MARK: -
     */
    
    static let CellID: String = "PackageCell"
    
    /*
     MARK: -
     */
    
    @IBOutlet private var imageContainerView: UIView!
    @IBOutlet private var imageView: AFInteractiveImageView!
    @IBOutlet private var titleLabel: AFLabel!
    
    @IBOutlet private var playButton: AFInteractiveView!
    @IBOutlet private var playButtonImageView: UIImageView!
    @IBOutlet weak var lockIcon: UIImageView!
  
    var package: Package! {
        willSet {
            notificationToken?.invalidate()
        }
        didSet {
            notificationToken = package.observe(keyPaths: [\Package.isPreviewPlaying], on: .main, { [weak self] change in
                switch change {
                case .error(let error):
                    print(error)
                case .change(_, _):
                    self?.updateUI()
                case .deleted:
                    self?.notificationToken?.invalidate()
                }
            })
          
          notificationToken = package.observe(keyPaths: [\Package.status], on: .main, { [weak self] change in
            
            switch change {
            case .error(let error):
              print("Observing Package Error: ", error)
            case .change(_, _):
              self?.updateUI()
            case .deleted:
              self?.notificationToken?.invalidate()
            }
            
          })
            
            updateUI()
        }
    }
    var selectAction: Closure?
    var previewCell: ((IndexPath) -> Void)?
    
  private var index: IndexPath?
  private var circleLayer = CAShapeLayer()
  private var progressLayer = CAShapeLayer()
  private var startPoint = CGFloat(-Double.pi / 2)
  private var endPoint = CGFloat(3 * Double.pi / 2)
    
    /*
     MARK: -
     */
    
    private var notificationToken: NotificationToken?
    
    /*
     MARK: -
     */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /*
         */
        
        imageContainerView.layer.cornerRadius = 12 * SizeFactor
        
        imageView.didTouchAction = { [weak self] in
            self?.selectAction?()
        }
        
        /*
         */
        
        playButton.isHidden = true
        playButton.didTouchAction = { [weak self] in
          guard let package = self?.package else { return }
          guard let index = self?.index else { return }
          
          if package.isPreviewPlaying {
            SoundManager.shared.stopCurrentPreview()
            self?.previewCell?(index)
            return
          } else {
            self?.previewCell?(index)
            self?.playButtonImageView.image = UIImage(named: "PauseButton")
            SoundManager.shared.playPreview(for: package) { [weak self] duration in
              self?.createCircularPath()
              self?.progressAnimation(duration: duration)
            }
          }
        }
      
      SoundManager.shared.didFinishPreview = { [weak self] flag in
        if flag {
          DispatchQueue.main.async {
            guard let index = self?.index else { return }
            self?.previewCell?(index)
          }
        }
      }
    }
  
  func progressAnimation(duration: TimeInterval) {
    let circularProgressAnimation = CABasicAnimation(keyPath: "strokeEnd")
    circularProgressAnimation.duration = duration
    circularProgressAnimation.toValue = 1.0
    circularProgressAnimation.fillMode = .forwards
    circularProgressAnimation.isRemovedOnCompletion = false
    progressLayer.add(circularProgressAnimation, forKey: "progressAnim")
  }
  
  func createCircularPath() {
    let circularPath = UIBezierPath(arcCenter: CGPoint(x: playButton.frame.size.width / 2.0,
                                                       y: playButton.frame.size.height / 2.0),
                                                       radius: 14,
                                                       startAngle: startPoint,
                                                       endAngle: endPoint,
                                                       clockwise: true)
    
    circleLayer.path = circularPath.cgPath
    circleLayer.fillColor = UIColor.clear.cgColor
    circleLayer.lineCap = .round
    circleLayer.lineWidth = 2.0
    circleLayer.strokeEnd = 1.0
    circleLayer.strokeColor = UIColor.clear.cgColor
    playButton.layer.addSublayer(circleLayer)
    progressLayer.path = circularPath.cgPath
    progressLayer.fillColor = UIColor.clear.cgColor
    progressLayer.lineCap = .round
    progressLayer.lineWidth = 2.0
    progressLayer.strokeEnd = 0
    progressLayer.strokeColor = UIColor.white.cgColor
    playButton.layer.addSublayer(progressLayer)
  }
    
 private func updateUI() {
      
      /*
        */
      
      titleLabel.text = package.title
      
      /*
        */
      
      if
          let imageURLString = package.imageURLString,
          let url = URL(string: imageURLString),
          let data = try? Data(contentsOf: url)
      {
          imageView.image = UIImage(data: data)
      } else {
        if let serverImage = package.serverImageURLString {
          imageView.sd_imageProgress = .current()
          imageView.sd_setImage(with: URL(string: serverImage))
        }
      }
    
    switch package.status {
    case .live:
      lockIcon.image = nil
    case .pro:
      lockIcon.image = UIImage(named: "lock")
    case .downloaded:
      lockIcon.image = UIImage(named: "download")
    }
      
      /*
        */
   
   if package.isPreviewPlaying {
     resetPreview()
   }
      
      if let _ = package {
          playButton.isHidden = false
          //playButtonImageView.image = UIImage(named: package.isPreviewPlaying ? "PauseButton" : "PlayButton")
      } else {
          playButton.isHidden = true
      }
  }
  
  func resetPreview() {
    SoundManager.shared.stopCurrentPreview()
    progressLayer.removeFromSuperlayer()
    circleLayer.removeFromSuperlayer()
    playButtonImageView.image = UIImage(named: "PlayButton")
  }
  
  func setIndex(index: IndexPath) {
    self.index = index
  }
}
