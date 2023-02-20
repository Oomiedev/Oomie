//
//  TutorialView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 11.02.2023.
//

import UIKit

final class TutorialView: UIView {
  
  var finishTutorial: (() -> Void)?
  
  let scrollView: UIScrollView = {
    let view = UIScrollView()
    view.bounces = false
    view.showsHorizontalScrollIndicator = false
    view.isPagingEnabled = true
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isScrollEnabled = false
    return view
  }()
  
  let stackView: UIStackView = {
    let view = UIStackView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .horizontal
    view.distribution = .fillEqually
    view.spacing = 0
    return view
  }()
  
  let screen1 = TutorialContentView(screenType: .first(count: 4))
  let screen2 = TutorialContentView(screenType: .second(count: 3))
  let screen3 = TutorialContentView(screenType: .third)
  

  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
    
    screen1.goToNextScreen = { [weak self] in
      guard let self = self else { return }
      let widthPoint = self.screen1.bounds.maxX
      let point = CGPoint(x: widthPoint, y: 0)
      self.scrollView.setContentOffset(point, animated: true)
    }
    
    screen2.goToNextScreen = { [weak self] in
      guard let self = self else { return }
      let widthPoint = self.screen1.bounds.maxX
      let point = CGPoint(x: widthPoint * 2, y: 0)
      self.scrollView.setContentOffset(point, animated: true)
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        self.screen3.addLayer()
      }
    }
    
    screen3.goToNextScreen = { [weak self] in
      guard let self = self else { return }
      self.finishTutorial?()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set() {
    stackView.addArrangedSubview(screen1)
    stackView.addArrangedSubview(screen2)
    stackView.addArrangedSubview(screen3)
    screen1.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    screen2.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
    screen3.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1).isActive = true
  }
}

private extension TutorialView {
  
  private func setupView() {
    isOpaque = true
    backgroundColor = UIColor(named: "Color 1")?.withAlphaComponent(0.65)
    addSubview(scrollView)
    scrollView.addSubview(stackView)
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      scrollView.heightAnchor.constraint(equalTo: heightAnchor),
      scrollView.centerYAnchor.constraint(equalTo: centerYAnchor),
      scrollView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor),
      scrollView.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),
    ])
  }
}
