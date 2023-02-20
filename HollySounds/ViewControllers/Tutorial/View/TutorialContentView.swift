//
//  TutorialContentView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 18.02.2023.
//

import UIKit
import AFKit

final class TutorialContentView: UIView {
  
  private var padViews: [TutorialPadView] = []
  
  private var pinView: UIView?
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.textColor = .oomieWhite
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.numberOfLines = 0
    return label
  }()
  
  private let playButton: AFInteractiveView = {
    let btn = AFInteractiveView()
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }()
  
  let playImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(named: "PlayIcon")
    imageView.contentMode = .scaleAspectFit
    imageView.isHidden = true
    return imageView
  }()
  
  var shapelayer = CAShapeLayer()
  
  private var screenType: TutorialScreen
  
  var goToNextScreen: (() -> Void)?
  
  init(screenType: TutorialScreen) {
    self.screenType = screenType
    super.init(frame: .zero)
    setupView()
    constraintView()
    titleLabel.text = screenType.title
    
    switch screenType {
    case .first(let count):
      setupFirst(count)
    case .second(let count):
      setupSecond(count)
    case .third:
      setupThird()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(screenType: TutorialScreen) {
    self.screenType = screenType
    switch screenType {
    case .first(let count):
      setupFirst(count)
    case .second(let count):
      setupSecond(count)
    case .third:
      setupThird()
    }
  }
  
  private func setupFirst(_ count: Int) {
    for i in 0..<count {
      let touchPadView = TutorialPadView()
      touchPadView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(touchPadView)
      padViews.append(touchPadView)
      
      if i == count - 1 {
        pinView = touchPadView
      }
      
      touchPadView.tap = { [weak self] in
        self?.goToNextScreen?()
      }
    }
    
    addSubview(titleLabel)
    guard let pinView = pinView else { return }
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
    titleLabel.bottomAnchor.constraint(equalTo: pinView.topAnchor, constant: -40).isActive = true
  }
  
  private func setupSecond(_ count: Int) {
    for i in 0..<count {
      let touchPadView = TutorialPadView()
      touchPadView.translatesAutoresizingMaskIntoConstraints = false
      addSubview(touchPadView)
      padViews.append(touchPadView)
      
      if i == count - 1 {
        pinView = touchPadView
      }
      
      touchPadView.tap = { [weak self] in
        self?.goToNextScreen?()
      }
    }
    
    addSubview(titleLabel)
    guard let pinView = pinView else { return }
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
    titleLabel.topAnchor.constraint(equalTo: pinView.bottomAnchor, constant: 40).isActive = true
  }
  
  private func setupThird() {
    addSubview(playButton)
    addSubview(titleLabel)
    playButton.addSubview(playImageView)
    
    playButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    playButton.widthAnchor.constraint(equalToConstant: 64).isActive = true
    playButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.5).isActive = true
    playButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 1.5).isActive = true
    
    playImageView.heightAnchor.constraint(equalToConstant: 34).isActive = true
    playImageView.widthAnchor.constraint(equalToConstant: 34).isActive = true
    playImageView.centerXAnchor.constraint(equalTo: playButton.centerXAnchor).isActive = true
    playImageView.centerYAnchor.constraint(equalTo: playButton.centerYAnchor).isActive = true
    
    titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
    titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
    titleLabel.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 24).isActive = true
    
    playButton.didTouchAction = { [weak self] in
      self?.goToNextScreen?()
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    var positionsMap: [CGPoint] = []
    
    var position = CGPoint(x: 0, y: OffsetY * 0.5)
    
    switch screenType {
    case .first:
      positionsMap = [CGPoint(x: OffsetX, y: -OffsetY * 0.5),
                      CGPoint(x: -OffsetX * 2, y: 0),
                      CGPoint(x: OffsetX,y: -OffsetY * 0.5)]
      position = CGPoint(x: 0, y: OffsetY * 0.5)
    case .second:
      positionsMap = [CGPoint(x: OffsetX, y: OffsetY * 0.5),
                      CGPoint(x: -OffsetX * 2, y: 0),
                      CGPoint(x: OffsetX,y: -OffsetY * 0.5)]
      position = CGPoint(x: 0, y: -OffsetY * 1.66)
    case .third:
      break
    }

    padViews.enumerated().forEach { [weak self] index, touchPadView in
      guard let self = self else { return }
      var size: CGFloat = 0
      switch screenType {
      case .first:
        size = index == 0 || index == 2 ? 50 : 45
      case .second:
        size = 50
      case .third:
        break
      }

      touchPadView.removeConstraints(touchPadView.constraints)
      
      let topConstraint =
      touchPadView.topAnchor
        .constraint(
          equalTo:
            self.topAnchor,
          constant:
            self.bounds.midY + position.y - CGFloat(size))
      
      let leadingConstraint =
      touchPadView.leadingAnchor
        .constraint(
          equalTo:
            self.leadingAnchor,
          constant:
            self.bounds.midX + position.x - TouchPadViewSize.height / 2)
      
      let widthConstraint =
      touchPadView.widthAnchor
        .constraint(equalToConstant:
                      TouchPadViewSize.width)
      
      let heighConstraint =
      touchPadView.heightAnchor
        .constraint(equalToConstant:
                      TouchPadViewSize.height)
      
      topConstraint.isActive = true
      leadingConstraint.isActive = true
      widthConstraint.isActive = true
      heighConstraint.isActive = true
      
      let offset = positionsMap[index % positionsMap.count]
      position.x += offset.x
      position.y += offset.y
    }
  }
  
  func addLayer() {
    playImageView.isHidden = false
    var size: CGFloat = 0.0
    let image = UIImage(named: "traiangle")?.cgImage
    
    for i in  0...3 {
      
      let myLayer = CALayer()
      if i == 0 {
        size = 26
      } else if i == 1 {
        size = 40
        myLayer.opacity = 0.65
      } else if i == 2 {
        size = 50
        myLayer.opacity = 0.35
      } else if i == 3 {
        size = 62
        myLayer.opacity = 0.15
      }
      
      
      let point = CGPoint(x: playImageView.bounds.midX + 2, y: playImageView.bounds.midY)
      myLayer.frame = CGRect(origin: point, size: CGSize(width: size, height: size))
      myLayer.position = point
      myLayer.contents = image
      playImageView.layer.contentsGravity = .center
      playImageView.layer.addSublayer(myLayer)
    }
  }
}

private extension TutorialContentView {
  private func setupView() {
    backgroundColor = .clear
  }
  private func constraintView() {}
}

enum TutorialScreen: CaseIterable {
  static var allCases: [TutorialScreen] = [.first(count: 4), .second(count: 3), .third]
  
  case first(count: Int),
       second(count: Int),
       third
  
  var title: String {
    switch self {
    case .first:
      return "Start the 1st sound layer"
    case .second:
      return "Add the second"
    case .third:
      return "Tap here to have Oomie pick the sound combinations by itself and non-stop"
    }
  }
}
