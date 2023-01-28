//
//  SoundPackService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 12.01.2023.
//

import Foundation
import RealmSwift

protocol SoundPackService {
  func clearOldPackages(complete: @escaping (() -> Void))
  func setupPackage(packsKeys: [String], completion: @escaping ((Bool, [SoundData]) -> Void))
  func setupServerPackage(packsKeys: [String: String], completion: @escaping ((Bool, [SoundData]) -> Void))
}

final class SoundPackServiceImpl {
  
  var soundDatas: [SoundData] = []
  
  let app = App(id: "oomie-nmqfg")
  var cloudRealm: Realm?
  
  init() {
    setupRealm()
  }
  
  func setupRealm(with completeAction: ((_ configuration: Realm.Configuration?) -> Void)? = nil) {
      var realmConfig = Realm.Configuration.defaultConfiguration
      realmConfig.schemaVersion = 0
      realmConfig.migrationBlock = { migration, oldSchemaVersion in
        if oldSchemaVersion < 1 {
          
        }
      }
    
    realmConfig.deleteRealmIfMigrationNeeded = true
    
      realmConfig.shouldCompactOnLaunch = { totalBytes, usedBytes in
          let limitBytes = 100 * 1024 * 1024
          let value = (totalBytes > limitBytes) && (Double(usedBytes) / Double(totalBytes)) < 0.5
          return value
      }
      
      realmConfig.objectTypes = [
          Settings.self,
          Package.self,
          Sound.self
      ]
      Realm.Configuration.defaultConfiguration = realmConfig
  }
}

extension SoundPackServiceImpl: SoundPackService {
  
  func clearOldPackages(complete: @escaping (() -> Void)) {
    let oldKeys = ["Sea Breeze", "Magic Forest", "Neon Ocean", "Desert Dawn"]
    let fileManager = FileManager.default
    
    do {
      let realm = try Realm()
      realm.beginWrite()
      
      oldKeys.forEach { [weak self] key in
        
        if let oldPackage = realm.object(ofType: Package.self, forPrimaryKey: key) {
          realm.delete(oldPackage)
        }
        
        if let path = createDestinationURL(with: key) {
          self?.removeDirectory(manager: fileManager, path: path)
        }
      }
      try realm.commitWrite()
      complete()
      
    } catch let error {
      print(error.localizedDescription)
      complete()
    }
  }
  
  private func removeDirectory(manager: FileManager, path: URL) {
    do {
      try manager.removeItem(at: path)
    } catch let error {
      print(error.localizedDescription)
    }
  }

  func setupPackage(packsKeys: [String], completion: @escaping ((Bool, [SoundData]) -> Void)) {
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
      resetSamples()
      completion(packageStatus, soundDatas)
      
      
    } catch let error {
      print("Error: ", error.localizedDescription)
      completion(false, soundDatas)
    }
  }
  
  func setupServerPackage(packsKeys: [String : String], completion: @escaping ((Bool, [SoundData]) -> Void)) {
    do {
      let realm = try Realm()
      realm.beginWrite()
      var packageStatus: Bool = false
      
      for (_, value) in packsKeys.enumerated() {
        if let _ = realm.object(ofType: Package.self, forPrimaryKey: value.key) {
          packageStatus = true
          try! realm.commitWrite()
          completion(packageStatus, soundDatas)
          return
        }

        let package = self.createServerPackage(value.key, img: value.value)
        realm.add(package)
        if let sourceURL = self.createSourceURL(with: value.key),
           let destinationURL = self.createDestinationURL(with: value.key) {
          
          let soundData = SoundData(package: package, sourceURL: sourceURL, destinationURL: destinationURL)
          self.soundDatas.append(soundData)
        }
      }
      
      packageStatus = true
      try! realm.commitWrite()
      completion(packageStatus, soundDatas)
      
    } catch let error {
      print("Error: ", error.localizedDescription)
      completion(false, soundDatas)
    }
  }
}

private extension SoundPackServiceImpl {
  private func resetSamples() {
    let realm = try! Realm()
    try? realm.safeWrite {
        let sounds = realm.objects(Sound.self)
        sounds.forEach { $0.state = .none }
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
    package.isProPack = false
    return package
  }
  
  private func createServerPackage(_ id: String, img: String) -> Package {
    let package = Package()
    package.id = id
    package.dateCreated = Date().timeIntervalSince1970
    package.title = id
    package.serverImageURLString = img
    package.isProPack = true
    return package
  }
}

struct SoundData {
  let package: Package
  let sourceURL: URL
  let destinationURL: URL
}
