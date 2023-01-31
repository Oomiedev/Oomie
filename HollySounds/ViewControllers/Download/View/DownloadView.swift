//
//  DownloadView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 22.01.2023.
//

import UIKit
import SDWebImage

final class DownloadView: UIView {
  
  private lazy var backgroundImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    return view
  }()
  
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
  
  private lazy var iconImageView: UIImageView = {
    let view = UIImageView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.contentMode = .scaleAspectFill
    view.layer.cornerRadius = 12
    view.layer.cornerCurve = .continuous
    view.clipsToBounds = true
    return view
  }()
  
   lazy var progressLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16, weight: .regular)
    label.textColor = .oomieWhite
    return label
  }()
  
  lazy var progressView: UIProgressView = {
    let view = UIProgressView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.progressTintColor = .oomieWhite
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupView()
    constraintView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func set(package: Package) {
    if let imageString = package.serverImageURLString {
      backgroundImageView.sd_setImage(with: URL(string: imageString))
      backgroundImageView.addBlur(0.9)
      iconImageView.sd_setImage(with: URL(string: imageString))
    }
    packNameLabel.text = package.title
    
  }
}

private extension DownloadView {
  private func setupView() {
    backgroundColor = .clear
    addSubview(backgroundImageView)
    addSubview(closeButton)
    addSubview(packNameLabel)
    addSubview(iconImageView)
    addSubview(progressLabel)
    addSubview(progressView)
  }
  
  private func constraintView() {
    NSLayoutConstraint.activate([
      backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
      backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      
      closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 21),
      closeButton.heightAnchor.constraint(equalToConstant: 32),
      closeButton.widthAnchor.constraint(equalToConstant: 32),
      
      packNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      packNameLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 30),
      
      iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      iconImageView.heightAnchor.constraint(equalToConstant: 300),
      iconImageView.widthAnchor.constraint(equalTo: iconImageView.heightAnchor),
      iconImageView.topAnchor.constraint(equalTo: packNameLabel.bottomAnchor, constant: 40),
      
      progressLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 64),
      progressLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      progressView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      progressView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
      progressView.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16)
    ])
  }
}
