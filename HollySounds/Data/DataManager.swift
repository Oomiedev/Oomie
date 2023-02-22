//
//  DataManager.swift
//  HollySounds
//
//  Created by Ne Spesha on 17.04.22.
//

import Foundation
import RealmSwift
import ZIPFoundation
import OggDecoder
import AFKit

let Email: String = "ne.spesha.official@gmail.com"
let Password: String = "daxcub-qyxpe1-fyTseh"

final class DataManager {
    
    /*
     MARK: -
     */
    
    static let shared = DataManager()
    
    /*
     MARK: -
     */
    
    let app = App(id: "oomie-nmqfg")
    var cloudRealm: Realm?
    
    /*
     MARK: -
     */
    
    func initialize(with completeAction: Closure?) {
        
        /*
         */
        
        setupRealm()
        
        /*
         */
        
        let realm = try! Realm()
        realm.beginWrite()
        
        let dispatchGroup = DispatchGroup()
        
        [
            "Sea Breeze",
            "Magic Forest",
            "Neon Ocean",
            "Desert Dawn"
        ].forEach { id in
            
            /*
             */
            
            var package = realm.object(
                ofType: Package.self,
                forPrimaryKey: id
            )
            
            /*
             */
            
            if package == nil, let sourceURL = Bundle.main.url(forResource: id, withExtension: "zip"),
                let destinationURL = URL.packeges?.appendingPathComponent(id) {

                dispatchGroup.enter()
                
                do {

                    try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                    try FileManager.default.unzipItem(
                        at: sourceURL, to: destinationURL)
                } catch {
                    print("Extraction of ZIP archive failed with error:\(error)")
                }
                
                package = Package()
                package?.id = id
                package?.dateCreated = Date().timeIntervalSince1970
                package?.title = id
                
                realm.add(package!)
                
                self.parseSamples(
                    to: package!,
                    from: destinationURL
                ) {
                    self.parseLoops(
                        to: package!,
                        from: destinationURL
                    ) {
                        dispatchGroup.leave()
                    }
                }
            }
        }
        
        try! realm.commitWrite()
        
        /*
         */
        
        resetSamples()
        
        /*
         */
        
        dispatchGroup.notify(queue: .main) {
            completeAction?()
        }
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
    
    private func parseSamples(
        to package: Package,
        from fileURL: URL,
        completeAction: Closure?
    ) {
        
        /*
         */
        
        let dispatchGroup = DispatchGroup()
        
//        for variation in 1...2 {
            for octave in 1...4 {
                Note.allCases.forEach { note in
                    
                    /*
                     */
                    
                    dispatchGroup.enter()
                    
                    /*
                     */
                    
                    let fileName = (note.stringValue ?? "") + "\(octave) 1"
                    
                    /*
                     */
                    
                    createSound(note, octave, fileURL, fileName) { sound in
                        if let sound = sound {
                            let realm = try! Realm()
                            try? realm.safeWrite {
                                package.sounds.append(sound)
                            }
                        }
                        
                        dispatchGroup.leave()
                    }
                }
            }
//        }
        
        /*
         */
        
        dispatchGroup.notify(queue: .main) {
            completeAction?()
        }
    }
    
    private func createSound(
        _ note: Note,
        _ octave: Int,
        _ fileURL: URL,
        _ fileName: String,
        _ completeAction: ((Sound?) -> Void)?
    ) {
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
        
        /*
         */
        
        let decoder = OGGDecoder()
        decoder.decode(oggURL, into: wavURL) { _ in
            
            /*
             */
            
            let sound = Sound()
            sound.type = .single
            sound.noteNumber = note.getNoteNumber(for: octave) ?? 0
            sound.soundFileName = fileName
            
            completeAction?(sound)
        }
    }
    
    private func parseLoops(
        to package: Package,
        from fileURL: URL,
        completeAction: Closure?
    ) {
        
        /*
         */
        
        let realm = try! Realm()
        let isInWriteTransaction = realm.isInWriteTransaction
        if isInWriteTransaction == false {
            realm.beginWrite()
        }
        
        /*
         */
        
        var timeInterval = Date().timeIntervalSince1970
        let decoder = OGGDecoder()
        
        let dispatchGroup = DispatchGroup()
        
        Ambience.allCases.forEach { ambience in
            
            /*
             */
            
            let fileName = (ambience.stringValue ?? "")
            
            let oggURL = fileURL
                .appendingPathComponent("Loops")
                .appendingPathComponent(fileName)
                .appendingPathExtension("ogg")
            let wavURL = fileURL
                .appendingPathComponent("Loops")
                .appendingPathComponent(fileName)
                .appendingPathExtension("wav")
            guard FileManager.default.fileExists(atPath: oggURL.path) else { return }
            
            /*
             */
            
            dispatchGroup.enter()
            
            /*
             */
            
            decoder.decode(oggURL, into: wavURL) { _ in
                dispatchGroup.leave()
            }
            
            /*
             */
            
            let sound = Sound()
            sound.type = ambience.loopType ?? .loop1
            sound.soundFileName = ambience.stringValue
            sound.index = ambience.index
            package.sounds.append(sound)
            
            timeInterval += 1
        }
        
        /*
         */
        
        if isInWriteTransaction == false {
            try? realm.commitWrite()
        }
        
        /*
         */
        
        dispatchGroup.notify(queue: .main) {
            completeAction?()
        }
    }
    
    func setupRealm(with completeAction: ((_ configuration: Realm.Configuration?) -> Void)? = nil) {
        
//        /*
//         */
//
//        app.emailPasswordAuth.registerUser(
//            email: Email,
//            password: Password,
//            completion: { [weak self] error in
//                DispatchQueue.main.async {
//                    guard error == nil else {
//                        completeAction?(nil)
//                        return
//                    }
//
//                    self?.signIn(with: completeAction)
//                }
//            }
//        )
        
//        signIn(with: completeAction)
        
        /*
         */
        
        var realmConfig = Realm.Configuration.defaultConfiguration
        realmConfig.schemaVersion = 0
        realmConfig.migrationBlock = { migration, oldSchemaVersion in
            
        }
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
    
    func signIn(with completeAction: ((_ configuration: Realm.Configuration?) -> Void)?) {
        
        app.login(
            credentials: Credentials.emailPassword(
                email: Email,
                password: Password
            )
        ) { [weak self] result in
            // Completion handlers are not necessarily called on the UI thread.
            // This call to DispatchQueue.main.async ensures that any changes to the UI,
            // namely disabling the loading indicator and navigating to the next page,
            // are handled on the UI thread:
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    completeAction?(nil)
                    return
                case .success(let user):
                    let configuration = user.configuration(partitionValue: "user=\(user.id)")
                    Realm.asyncOpen(configuration: configuration) { [weak self] result  in
                        DispatchQueue.main.async {
                            
                            switch result {
                            case .failure(let error):
                                completeAction?(nil)
                            case .success:
                                completeAction?(configuration)
                            }
                        }
                    }
                }
            }
        }
    }
    
}
