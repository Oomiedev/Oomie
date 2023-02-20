//
//  TutorialViewController.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 11.02.2023.
//

import UIKit

final class TutorialViewController: UIViewController {

  let rootView = TutorialView()
  
  override func loadView() {
    view = rootView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    definesPresentationContext = true
    rootView.set()
  }
}
