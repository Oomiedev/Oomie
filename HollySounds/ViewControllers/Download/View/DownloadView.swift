//
//  DownloadView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 22.01.2023.
//

import UIKit

final class DownloadView: UIView {
  
  let closeButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setImage(UIImage(named: "CloseIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
    return btn
  }()
  
  private lazy var packNameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 24, weight: .bold)
    label.textColor = .oomieWhite
    return label
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(packName: String) {
    packNameLabel.text = packName
  }
}

private extension DownloadView {
  private func setupView() {
    backgroundColor = .onboardingBackground
    addSubview(closeButton)
    addSubview(packNameLabel)
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 21),
      closeButton.heightAnchor.constraint(equalToConstant: 32),
      closeButton.widthAnchor.constraint(equalToConstant: 32),
      
      packNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      packNameLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
    ])
  }
}
