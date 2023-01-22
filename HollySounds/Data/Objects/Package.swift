//
//  Package.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import Foundation
import RealmSwift

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
  
  @Persisted
    var serverImageURLString: String?
  
  @Persisted
  var isProPack: Bool = false
    
    @Persisted
    var sounds = List<Sound>()
    
    /*
     MARK: -
     */
    
    func download() {
        
    }
}
