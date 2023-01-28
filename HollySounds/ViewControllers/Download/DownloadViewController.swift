//
//  DownloadViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 22.01.2023.
//

import UIKit

final class DownloadViewController: UIViewController {
  
  let rootView = DownloadView()
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    rootView.closeButton.addTarget(self, action: #selector(didTapCloseBtn), for: .touchUpInside)
  }
  
  @objc private func didTapCloseBtn() {
    dismiss(animated: true)
  }
}
