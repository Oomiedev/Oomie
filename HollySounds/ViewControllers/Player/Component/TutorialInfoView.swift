//
//  TutorialInfoView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 11.03.2023.
//

import UIKit

final class TutorialInfoView: UIView {

  private var tutorialLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.numberOfLines = 0
    label.textAlignment = .center
    label.textColor = .oomieWhite
    label.text = "Start the 1st\n sound layer"
    label.font = .systemFont(ofSize: 24, weight: .medium)
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    backgroundColor = .black.withAlphaComponent(0.8)
    layer.cornerRadius = 16
    layer.cornerCurve = .continuous
    layer.borderColor = UIColor.buttonPrimary.cgColor
    layer.borderWidth = 2
  }
  
  private func setupView() {
    addSubview(tutorialLabel)
    tutorialLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24).isActive = true
    tutorialLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24).isActive = true
    tutorialLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
  }
  
  func set(tutorial: Tutorial) {
    if tutorial == .thirdScreen {
      tutorialLabel.textAlignment = .left
    } else {
      tutorialLabel.textAlignment = .center
    }
    tutorialLabel.text = tutorial.description
  }
}
