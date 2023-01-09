//
//  UserDefaultsStorage.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 08.01.2023.
//

import Foundation

struct UserDefaultsStorage: Storage {
  
  private let userDefaults = UserDefaults.standard
  
  func bool(for key: Key) -> Bool {
    return self.userDefaults.bool(forKey: key)
  }
  
  func set(_ newValue: Bool, for key: Key) {
    self.userDefaults.set(newValue, forKey: key)
  }
}
