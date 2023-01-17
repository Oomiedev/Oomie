//
//  DecodingService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 13.01.2023.
//

import Foundation
import OggDecoder
import RealmSwift

protocol DecodingService: AnyObject {
  func decodeLoops(packs: [SoundData], completion: @escaping ((Bool) -> Void))
}

final class DecodingServiceImpl {
  
  private let realm = try! Realm()
}

extension DecodingServiceImpl: DecodingService {
  func decodeLoops(packs: [SoundData], completion: @escaping ((Bool) -> Void)) {
    for pack in packs {
      
      let isInWriteTransaction = realm.isInWriteTransaction
      if isInWriteTransaction == false {
        realm.beginWrite()
      }
      
      var timeInterval = Date().timeIntervalSince1970
      let decoder = OGGDecoder()
      
      let dispatchGroup = DispatchGroup()
      
      Ambience.allCases.forEach { ambience in
        
        let fileName = (ambience.stringValue ?? "")
        
        let oggURL = pack.destinationURL
          .appendingPathComponent("Loops")
          .appendingPathComponent(fileName)
          .appendingPathExtension("ogg")
        let wavURL = pack.destinationURL
          .appendingPathComponent("Loops")
          .appendingPathComponent(fileName)
          .appendingPathExtension("wav")
        guard FileManager.default.fileExists(atPath: oggURL.path) else { return }
        
          dispatchGroup.enter()
          decoder.decode(oggURL, into: wavURL) { result in
            dispatchGroup.leave()
          }

        let sound = Sound()
        sound.type = ambience.loopType ?? .loop1
        sound.soundFileName = ambience.stringValue
        sound.index = ambience.index
        pack.package.sounds.append(sound)
        
        timeInterval += 1
      }
      
      if isInWriteTransaction == false {
        try? self.realm.commitWrite()
      }
      
      dispatchGroup.notify(queue: .main) {
        completion(true)
      }
    }
  }
}
