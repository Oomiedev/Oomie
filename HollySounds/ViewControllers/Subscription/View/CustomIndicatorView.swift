//
//  CustomIndicatorView.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov on 19.04.2023.
//

import UIKit

final class CustomIndicatorView: UIView {
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 16, weight: .medium)
    label.textColor = .white
    label.text = "Please wait..."
    return label
  }()
  
  private let indicatorView: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = .oomieWhite
    view.hidesWhenStopped = true
    view.startAnimating()
    return view
  }()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .black
    addSubview(indicatorView)
    addSubview(titleLabel)
    
    NSLayoutConstraint.activate([
      indicatorView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      indicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
      
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
      titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
    ])
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    layer.cornerRadius = 8
    layer.cornerCurve = .continuous
  }
}
