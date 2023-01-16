//
//  SoundPackService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 12.01.2023.
//

import Foundation
import RealmSwift

protocol SoundPackService {
  func setupPackage(completion: @escaping ((Bool, [SoundData]) -> Void))
}

final class SoundPackServiceImpl {
  let packsKeys: [String] = ["Sea Breeze", "Magic Forest", "Neon Ocean", "Desert Dawn"]
  
  var soundDatas: [SoundData] = []
  
  let app = App(id: "oomie-nmqfg")
  var cloudRealm: Realm?
}

extension SoundPackServiceImpl: SoundPackService {
  
  func setupPackage(completion: @escaping ((Bool, [SoundData]) -> Void)) {
    do {
      let realm = try Realm()
      realm.beginWrite()
      var packageStatus: Bool = false
      packsKeys.forEach { key in
        if let _ = realm.object(ofType: Package.self, forPrimaryKey: key) {
          resetSamples()
          packageStatus = true
          return
        }

        let package = self.createPackage(key)
        realm.add(package)
        if let sourceURL = self.createSourceURL(with: key),
           let destinationURL = self.createDestinationURL(with: key) {
          
          let soundData = SoundData(package: package, sourceURL: sourceURL, destinationURL: destinationURL)
          self.soundDatas.append(soundData)
        }
      }
      
      try! realm.commitWrite()
      completion(packageStatus, soundDatas)
      
      
    } catch let error {
      print("Error: ", error.localizedDescription)
      completion(false, soundDatas)
    }
  }
  
  private func createSourceURL(with key: String) -> URL? {
    return Bundle.main.url(forResource: key, withExtension: "zip")
  }
  
  private func createDestinationURL(with key: String) -> URL? {
    return URL.packeges?.appendingPathComponent(key)
  }
  
  private func createPackage(_ id: String) -> Package {
    let package = Package()
    package.id = id
    package.dateCreated = Date().timeIntervalSince1970
    package.title = id
    
    return package
  }
  
  private func resetSamples() {
    let realm = try! Realm()
    try? realm.safeWrite {
        let sounds = realm.objects(Sound.self)
        sounds.forEach {
            $0.state = .none
        }
    }
  }
}

struct SoundData {
  let package: Package
  let sourceURL: URL
  let destinationURL: URL
}
