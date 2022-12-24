//
//  Settings.swift
//  Dating
//
//  Created by Ne Spesha on 5.07.21.
//

import Foundation
import RealmSwift

enum Sections: Int {
    
    case Gallery = 0,
         Profile
    
    var title: String? {
        let map: [Sections: String] = [
            .Gallery: "Gallery",
            .Profile: "Profile"
        ]
        
        return map[self]
    }
    
}

fileprivate var SettingsID: String = "Settings"

final class Settings: Object {
    
    /*
     MARK: -
     */
    
    static var current: Settings {
        get {
            
            let realm = try! Realm()
            var settings = realm.object(
                ofType: Settings.self,
                forPrimaryKey: SettingsID
            )
            
            if settings == nil {
                settings = Settings()
                settings!.id = SettingsID
                try! realm.safeWrite {
                    realm.add(settings!)
                }
            }
            
            return settings!
        }
    }
    
    /*
     MARK: -
     */
    
    @Persisted(primaryKey: true)
    var id: String = SettingsID
    
    /*
     Selected index in TabBar.
     */
    
    @Persisted
    var currentSectionIndex: Int = 0
    
}
