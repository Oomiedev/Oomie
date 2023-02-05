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
  var updateUIWithFetchedPackage: (() -> Void)?
  var updateSubscription: (() -> Void)?
  
  func observe(job: Job) {
    proccessToken = job.observe(\.loadingProccess, options: [.new], changeHandler: { [weak self] job, change in
      guard let jobProssess = change.newValue else { return }
      self?.updateUI?(jobProssess)
    })
    
    proccessToken = job.observe(\.fetchingProcess, options: [.new], changeHandler: { [weak self] job, change in
      guard let _ = change.newValue else { return }
      self?.updateUIWithFetchedPackage?()
    })
  }
}

final class Job: NSObject {
  @objc dynamic var loadingProccess: Bool = false
  @objc dynamic var fetchingProcess: Bool = false
}
