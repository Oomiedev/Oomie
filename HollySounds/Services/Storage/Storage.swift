//
//  Storage.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 08.01.2023.
//

import Foundation

typealias Key = String

protocol Storage {
  func bool(for key: Key) -> Bool
  func set(_ newValue: Bool, for key: Key)
}
