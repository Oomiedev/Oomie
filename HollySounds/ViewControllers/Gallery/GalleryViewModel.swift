//
//  GalleryViewModel.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 13.01.2023.
//

import Foundation

final class GalleryViewModel {
  
  private var proccessToken: NSKeyValueObservation?
  
  var updateUI: ((Bool) -> Void)?
  
  func observe(job: Job) {
    proccessToken = job.observe(\.loadingProccess, options: [.new], changeHandler: { [weak self] job, change in
      guard let jobProssess = change.newValue else { return }
      print("1111-0 ", jobProssess)
      self?.updateUI?(jobProssess)
    })
  }
}

final class Job: NSObject {
  @objc dynamic var loadingProccess: Bool = false
}
