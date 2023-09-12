//
//  Package.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import Foundation
import RealmSwift

enum PackageStatus: Int, PersistableEnum {
  case live, pro, downloaded
}

final class Package: Object {
    
    /*
     MARK: -
     */
    
    @Persisted(primaryKey: true)
    var id: String!
    
    @Persisted
    var title: String!
    
    @Persisted
    var dateCreated: Double = 0
    
    @Persisted
    var urlString: String?
    
    @Persisted
    var isPreviewPlaying: Bool = false
    
    var imageURLString: String? {
        let destinationURL = URL.packeges?.appendingPathComponent(id)
        return destinationURL?
            .appendingPathComponent("Image")
            .appendingPathExtension("png")
            .absoluteString
    }
    
    var videoURLString: String? {
        let destinationURL = URL.packeges?.appendingPathComponent(id)
        return destinationURL?
            .appendingPathComponent("Video")
            .appendingPathExtension("mp4")
            .absoluteString
    }
    
    var previewURLString: String? {
        return Bundle.main.url(forResource: id + " Preview", withExtension: "wav")?.absoluteString
    }
    
    var downloadedURLString: String? {
        let pathComponent = id + " Preview"
        let directoryURL: URL = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
        let folderPath: URL = directoryURL.appendingPathComponent("Packages/\(pathComponent)", isDirectory: true)
        return Bundle.url(forResource: pathComponent, withExtension: "wav", subdirectory: nil, in: folderPath)?.absoluteString
    }
  
  @Persisted
    var serverImageURLString: String?
  
  @Persisted
  var isProPack: Bool = false
  
  @Persisted
  var isDownloaded: Bool = true
  
  @Persisted
  var packDownloadURLString: String?
  
  @Persisted
  var status: PackageStatus = .live
    
    @Persisted
    var sounds = List<Sound>()
    
    /*
     MARK: -
     */
    
    func download() {
        
    }
}
