//
//  URL+Extension.swift
//  HollySounds
//
//  Created by Ne Spesha on 19.06.22.
//

import Foundation

extension URL {
    
    static var packeges: URL? {
        guard
            var url = FileManager.default
                .urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                )
                .first
        else {
            return nil
        }
        
        url = url.appendingPathComponent("Packages")
        if FileManager.default.fileExists(atPath: url.absoluteString) == false {
            try? FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: false
            )
        }
        
        return url
    }
    
}
