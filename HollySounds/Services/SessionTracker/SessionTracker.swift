//
//  SessionTracker.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 08.01.2023.
//

import Foundation

protocol SessionTracker: AnyObject {
  var isFirstLaunch: Bool { get set }
  var isPlayedBefore: Bool { get set }
}

final class SessionTrackerImpl {
  
  private let storage: Storage
  
  init(storage: Storage) {
    self.storage = storage
  }
}

extension SessionTrackerImpl: SessionTracker {
  var isFirstLaunch: Bool {
    get {
      !storage.bool(for: AppConstants.SessionTracker.Key.launchedBefore)
    }
    set {
      storage.set(!newValue, for: AppConstants.SessionTracker.Key.launchedBefore)
    }
  }
  
  var isPlayedBefore: Bool {
    get {
      !storage.bool(for: AppConstants.SessionTracker.Key.playedBefore)
    } set {
      storage.set(!newValue, for: AppConstants.SessionTracker.Key.playedBefore)
    }
  }
}
