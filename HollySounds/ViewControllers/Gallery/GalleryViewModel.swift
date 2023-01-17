//
//  GalleryViewModel.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 13.01.2023.
//

import Foundation

final class GalleryViewModel {
  
  var updatUI: (() -> ())?
  
  let decodingService: DecodingService?
  let isDecoded: Bool
  let packs: [SoundData]
  
  init(decodingService: DecodingService? = nil, isDecoded: Bool, packs: [SoundData]) {
    self.decodingService = decodingService
    self.isDecoded = isDecoded
    self.packs = packs
  }
  
  func decode() {
    decodingService?.decodeLoops(packs: packs) { [weak self] status in
      if status {
        self?.updatUI?()
      }
    }
  }
}
