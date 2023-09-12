//
//  ArchivingService.swift
//  HollySounds
//
//  Created by Nurlan Akylbekov  on 12.01.2023.
//

import Foundation
import RealmSwift
import OggDecoder

protocol ArchivingService: AnyObject {
  func unzip(data: [SoundData], completion: @escaping((Bool) -> Void))
    func unzipPreview(destinationURL: URL, sourceURL: URL, key: String, completion: @escaping((Bool) -> Void))
}

final class ArchivingServiceImpl {
  
  private let realm = try! Realm()
  private let backgroundQueue = DispatchQueue.global(qos: .background)
}

extension ArchivingServiceImpl: ArchivingService {
    
    func unzipPreview(destinationURL: URL, sourceURL: URL, key: String, completion: @escaping ((Bool) -> Void)) {
        backgroundQueue.async {
            
            do {
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
            } catch let error {
                print("Error: ", error)
            }
            
            do {
                
                try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                try FileManager.default.unzipItem(at: sourceURL, to: destinationURL)
                self.createPreview(fileURL: destinationURL,
                                   fileName: key) {
                    if FileManager.default.fileExists(atPath: sourceURL.path) {
                        try? FileManager.default.removeItem(at: sourceURL)
                    }
                    completion(true)
                }
            } catch let error {
                print(error)
                completion(false)
            }
        }
    }
    
  func unzip(data: [SoundData], completion: @escaping ((Bool) -> Void)) {
    
    let group = DispatchGroup()
    
    backgroundQueue.sync {
      for pack in data {
        group.enter()
        
        do {
          try FileManager.default.createDirectory(at: pack.destinationURL, withIntermediateDirectories: true, attributes: nil)
          
          try FileManager.default.unzipItem(at: pack.sourceURL, to: pack.destinationURL)
          
          self.parseSamples(sample: pack) {
            group.leave()
          }
          
        } catch let error {
          print(error)
        }
      }
      
      group.notify(queue: .main) {
        completion(true)
      }
    }
  }
  
  private func parseSamples(sample: SoundData, completion: @escaping (() -> Void)) {
    
    defer {
      completion()
    }
    
    for octave in 1...4 {
      Note.allCases.forEach { note in
        
        let fileName = (note.stringValue ?? "") + "\(octave) 1"
        createSound(note, octave, sample.destinationURL, fileName) { sound in
          guard let sound = sound else { return }
          try? self.realm.safeWrite({
            sample.package.status = .live
            sample.package.sounds.append(sound)
          })
        }
      }
    }
  }
  
  private func createSound(_ note: Note, _ octave: Int, _ fileURL: URL, _ fileName: String, _ completeAction: ((Sound?) -> Void)?) {
      let oggURL = fileURL
          .appendingPathComponent("Samples")
          .appendingPathComponent(fileName)
          .appendingPathExtension("ogg")
      let wavURL = fileURL
          .appendingPathComponent("Samples")
          .appendingPathComponent(fileName)
          .appendingPathExtension("wav")
      guard FileManager.default.fileExists(atPath: oggURL.path) else {
          completeAction?(nil)
          return
      }
      
      let decoder = OGGDecoder()
      decoder.decode(oggURL, into: wavURL) { _ in
          let sound = Sound()
          sound.type = .single
          sound.noteNumber = note.getNoteNumber(for: octave) ?? 0
          sound.soundFileName = fileName
          
          completeAction?(sound)
      }
  }
    
  private func createPreview(fileURL: URL, fileName: String, completion: (() -> Void)?) {
      let oggURL = fileURL
          .appendingPathComponent(fileName)
          .appendingPathExtension("ogg")
      let wavURL = fileURL
          .appendingPathComponent(fileName)
          .appendingPathExtension("wav")
      guard FileManager.default.fileExists(atPath: oggURL.path) else {
          completion?()
          return
      }
      
      let decoder = OGGDecoder()
      decoder.decode(oggURL, into: wavURL) {_ in
          completion?()
      }
    }
}
