//
//  AppConstants.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 08.01.2023.
//

import Foundation

enum AppConstants {
  
  enum SessionTracker {
    enum Key {
      static let launchedBefore = "sessionTracker.key.launchedBefore"
      static let playedBefore = "sessionTracker.key.playedBefore"
    }
  }
  
  enum API {
    static let baseURL = "http://104.248.89.173:1337"
    
    enum Pack {
      static let list = "/api/music-packs?populate=*"
    }
  }
}
