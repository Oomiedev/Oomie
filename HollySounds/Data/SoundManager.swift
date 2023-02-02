//
//  SoundManager.swift
//  HollySounds
//
//  Created by Ne Spesha on 5.04.22.
//

import Foundation
import AVFoundation
import RealmSwift

fileprivate final class ServiceVolume {
    var value: Float = 0
    var node: AVAudioPlayerNode!
}

final class SoundManager: NSObject {
    
    /*
     */
    
    static let shared = SoundManager()
    
    /*
     */
    
    var previewPlayer: AVAudioPlayer?
    
    /*
     */
    
    @objc
    dynamic var isAutoplayEnabled: Bool = false {
        didSet {
            if isAutoplayEnabled {
                
                /*
                 Stop playing all current loops.
                 */
                
                stackLoops
                    .filter {
                        $0.key.state == .playing
                    }
                    .forEach { (key: Sound, value: AVAudioPlayerNode) in
                        let service = getOrCreateVolumeService(
                            sound: key,
                            node: value
                        )
                        service.value = -FadeStep
                        
                        /*
                         */
                        
                        try! key.realm?.write {
                            key.state = .none
                        }
                    }
                
                /*
                 Select and play loops for autoplay.
                 */
                
                var soundsToStart: [Sound] = []
                var soundsToSkip: [Sound] = []
                var type = SoundType.loop1
                
                if
                    let sound = package.sounds
                        .filter({ $0.type == type })
                        .shuffled()
                        .first,
                    stackLoops.contains(where: { (key: Sound, value: AVAudioPlayerNode) in
                        key.soundFileName == sound.soundFileName
                    }) == false
                {
                    soundsToStart.append(sound)
                }
                
                /*
                 */
                
                type = SoundType.loop3
                
                if
                    let sound = package.sounds
                        .filter({ $0.type == type })
                        .shuffled()
                        .first,
                    stackLoops.contains(where: { (key: Sound, value: AVAudioPlayerNode) in
                        key.soundFileName == sound.soundFileName
                    }) == false
                {
                    soundsToStart.append(sound)
                }
                
                /*
                 */
                
                type = SoundType.loop2
                
                if
                    let sound = package.sounds
                        .filter({ $0.type == type })
                        .shuffled()
                        .first,
                    stackLoops.contains(where: { (key: Sound, value: AVAudioPlayerNode) in
                        key.soundFileName == sound.soundFileName
                    }) == false
                {
                    soundsToSkip.append(sound)
                }
                
                /*
                 */
                
                soundsToStart.forEach { sound in
                    playAndScheduleNext(sound)
                }
                
                soundsToSkip.forEach { sound in
                    playAndScheduleNext(sound, false)
                }
            } else {
                NSObject.cancelPreviousPerformRequests(withTarget: self)
            }
        }
    }
    
    /*
     */
    
    @objc
    dynamic var isRecordingEnabled: Bool = false
    
    private var url: URL!
    private var file: AVAudioFile!
    
    private var package: Package!
    
    /*
     */
    
    private var audioEngine = AVAudioEngine()
    
    private var audioPCMBuffers: [Sound: AVAudioPCMBuffer] = [:]
    private var stackLoops: [Sound: AVAudioPlayerNode] = [:]
    
    private var mixer = AVAudioMixerNode()
    private var sampler = AVAudioUnitSampler()
    
    private var displayLink: CADisplayLink?
    
    private var services: [ServiceVolume] = []
    
    /*
     */
    
    func initialize() {
        
        /*
         */
        
        try! AVAudioSession.sharedInstance().setCategory(.playback)
//        try! AVAudioSession.sharedInstance().setActive(true)
        
//        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        stopCurrentPreview()
    }
    
    /*
     MARK: -
     */
    
    func playPreview(for package: Package) {
        guard let url = URL(string: package.previewURLString ?? "" ) else { return }
        
        previewPlayer = try? AVAudioPlayer(contentsOf: url)
        previewPlayer?.volume = 0
        previewPlayer?.numberOfLoops = -1
        previewPlayer?.play()
        
        previewPlayer?.setVolume(1, fadeDuration: 3)
        
        try! package.realm?.safeWrite {
            package.isPreviewPlaying = true
        }
    }
    
    func stopCurrentPreview() {
        
        /*
         TO-DO:
         */
      
      do {
        
        let realm = try Realm()
        let packages = realm.objects(Package.self)
          .where {
            $0.isPreviewPlaying == true
          }
        
        try realm.safeWrite({
          for package in packages {
            package.isPreviewPlaying = false
          }
        })
        
      } catch let error {
        print("1111-0 ", error)
      }
        
        /*
         */
        
        previewPlayer?.stop()
        previewPlayer = nil
    }
    
    /*
     MARK: -
     */
    
    func startEngine(for package: Package) {
        
        /*
         */
        
        self.package = package
        
        /*
         */
        
        audioEngine.attach(mixer)
        audioEngine.connect(
            mixer,
            to: audioEngine.mainMixerNode,
            format: nil
        )
        
        /*
         */

        try? audioEngine.start()
        
        /*
         */
        
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateVolumes)
        )
        displayLink?.preferredFramesPerSecond = Int(1 / Double(FadeStep) / FadeLength)
        displayLink?.add(
            to: .main,
            forMode: .common
        )
        
        /*
         */
        
        url = URL(fileURLWithPath: "\(NSTemporaryDirectory())\(Date().timeIntervalSince1970).caf")
        file = try! AVAudioFile(
            forWriting: url,
            settings: audioEngine.mainMixerNode.outputFormat(forBus: 0).settings
        )
        audioEngine.mainMixerNode.installTap(
            onBus: 0,
            bufferSize: 4096,
            format: file.processingFormat
        ) { [weak self] (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            guard let self = self else { return }
            
            if self.isRecordingEnabled {
                do {
                    try self.file.write(from: buffer)
                } catch {
                    print("Writing problem")
                }
            }
        }
        
        /*
         */
        
        setupSamples()
        setupLoops()
    }
    
    @objc
    func play(
        sound: Sound,
        velocity: UInt8 = 127
    ) {
        
        /*
         */
        
        if sound.type == .single {
                
            /*
             */
            
            sampler.startNote(
                UInt8(sound.noteNumber),
                withVelocity: velocity,
                onChannel: 0
            )
            
            /*
             */
            
            try! sound.realm?.write {
                sound.state = .playing
            }
        } else {
            
            /*
             Stop other playing pad with the same type.
             */
            
            if
                let keyValue = stackLoops.first(
                    where: { (key: Sound, value: AVAudioPlayerNode) in
                        key.type == sound.type && key.state == .playing && key.soundFileName != sound.soundFileName
                    }
                )
            {
                
                let service = getOrCreateVolumeService(
                    sound: keyValue.key,
                    node: keyValue.value
                )
                service.value = -FadeStep
                
                /*
                 */
                
                try! keyValue.key.realm?.write {
                    keyValue.key.state = .none
                }
            }
            
            /*
             If loop is playing we need just turn the volume up or down.
             */
            
            if
                let keyValue = stackLoops.first(
                    where: { (key: Sound, value: AVAudioPlayerNode) in
                        return key.soundFileName == sound.soundFileName
                    }
                )
            {
 
                let service = getOrCreateVolumeService(
                    sound: keyValue.key,
                    node: keyValue.value
                )
                service.value = keyValue.key.state == .none ? FadeStep : -FadeStep
                
                /*
                 */
                
                try! sound.realm?.write {
                    keyValue.key.state = keyValue.key.state == .none ? .playing : .none
                }
            } else {
                
                if
                    let keyValue = audioPCMBuffers.first(where: { (key: Sound, value: AVAudioPCMBuffer) in
                        key.soundFileName == sound.soundFileName
                    })
                {
                    /*
                     */
                    
                    let audioPlayerNode = AVAudioPlayerNode()
                    audioEngine.attach(audioPlayerNode)
                    audioEngine.connect(
                        audioPlayerNode,
                        to: mixer,
                        format: nil
                    )
                    
                    /*
                     */
                    
                    audioPlayerNode.scheduleBuffer(
                        keyValue.value,
                        at: nil,
                        options: .loops,
                        completionHandler: nil
                    )

                    /*
                     */
                    
                    audioPlayerNode.volume = 0
                    audioPlayerNode.play()
                    
                    /*
                     */
                    
                    let service = getOrCreateVolumeService(
                        sound: sound,
                        node: audioPlayerNode
                    )
                    service.value = FadeStep
                    
                    /*
                     */
                    
                    try! sound.realm?.write {
                        keyValue.key.state = .playing
                    }
                    
                    /*
                     */
                    
                    stackLoops[sound] = audioPlayerNode
                }
            }
        }
    }
    
    func stop(sound: Sound) {
        
        if
            let keyValue = stackLoops.first(
                where: { (key: Sound, value: AVAudioPlayerNode) in
                    return key.soundFileName == sound.soundFileName
                }
            )
        {

            let service = getOrCreateVolumeService(
                sound: keyValue.key,
                node: keyValue.value
            )
            service.value = keyValue.key.state == .none ? FadeStep : -FadeStep
            
            /*
             */
            
            try! sound.realm?.write {
                keyValue.key.state = keyValue.key.state == .none ? .playing : .none
            }
        }
    }
    
    private func setupSamples() {
        
        /*
         */
        
        audioEngine.attach(sampler)
        audioEngine.connect(
            sampler,
            to: mixer,
            format: nil
        )
        
        /*
         */
        
        let sounds = package.sounds.where {
            $0.type == .single
        }
        
        /*
         */
        
        var urls: [URL] = []
        for sound in sounds {
            
            /*
             */
            
            guard
                let url = URL.packeges?
                    .appendingPathComponent(package.id)
                    .appendingPathComponent("Samples")
                    .appendingPathComponent(sound.soundFileName)
                    .appendingPathExtension("wav"),
                let audioFile = try? AVAudioFile(forReading: url),
                let audioPCMBuffer = AVAudioPCMBuffer(
                    pcmFormat: audioFile.processingFormat,
                    frameCapacity: AVAudioFrameCount(audioFile.length)
                )
            else { continue }
            
            /*
             */

            try? audioFile.read(into: audioPCMBuffer)
            audioPCMBuffers[sound] = audioPCMBuffer
            
            /*
             */
            
            urls.append(url)
        }
        
        /*
         */
        
        do {
            try sampler.loadAudioFiles(at: urls)
        } catch {
            print("Error")
        }
    }
    
    private func setupLoops() {
        
        /*
         */
        
        let sounds = package.sounds.where {
            $0.type == .loop1 || $0.type == .loop2 || $0.type == .loop3
        }
        
        /*
         */
        
        for sound in sounds {
            
            /*
             */
            
            guard
                let url = URL.packeges?
                    .appendingPathComponent(package.id)
                    .appendingPathComponent("Loops")
                    .appendingPathComponent(sound.soundFileName)
                    .appendingPathExtension("wav"),
                let audioFile = try? AVAudioFile(forReading: url),
                let audioPCMBuffer = AVAudioPCMBuffer(
                    pcmFormat: audioFile.processingFormat,
                    frameCapacity: AVAudioFrameCount(audioFile.length)
                )
            else { continue }
            
            /*
             */
            
            try? audioFile.read(into: audioPCMBuffer)
            audioPCMBuffers[sound] = audioPCMBuffer
        }
    }
    
    /*
     MARK: -
     */
    
    private func getOrCreateVolumeService(
        sound: Sound,
        node: AVAudioPlayerNode
    ) -> ServiceVolume {
        if
            let service = services.first(
                where: { service in
                    service.node == node
                }
            )
        {
            return service
        } else {
            let service = ServiceVolume()
            service.node = node
            services.append(service)
            return service
        }
    }
    
    @objc
    private func updateVolumes() {
        
        /*
         */
        
        var servicesToRemove: [ServiceVolume] = []
        var soundsToRemove: [Sound] = []
        for service in services {
            
            service.node.volume += service.value
            
            if service.value > 0 && service.node.volume >= 1 {
                servicesToRemove.append(service)
            } else if service.value < 0 && service.node.volume <= 0 {
                servicesToRemove.append(service)
                if
                    let keyValue = stackLoops.first(where: { (key: Sound, value: AVAudioPlayerNode) in
                        value == service.node
                    })
                {
                    soundsToRemove.append(keyValue.key)
                }
            }
        }
        
        servicesToRemove.forEach { serviceToRemove in
            if
                let index = services.firstIndex(where: { service in
                    service.node == serviceToRemove.node
                })
            {
                services.remove(at: index)
            }
        }
        
        soundsToRemove.forEach { soundToRemove in
            if
                let index = stackLoops.firstIndex(where: { (key: Sound, value: AVAudioPlayerNode) in
                    key.soundFileName == soundToRemove.soundFileName
                })
            {
                stackLoops.remove(at: index)
            }
        }
    }
    
    /*
     MARK: - Autoplay
     */
    
    @objc
    private func playNextLoop(for sound: Sound) {

        /*
         */
        
        let sounds = package.sounds
            .where({
                $0.type == sound.type && $0.state != .playing
            })
        
        if let nextSound = sounds.randomElement() {
            if nextSound.type == .loop1 {
                playAndScheduleNext(nextSound)
            } else {
                if sound.state == .none {
                    playAndScheduleNext(
                        nextSound,
                        true
                    )
                } else {
                    playAndScheduleNext(
                        nextSound,
                        false
                    )
                    
                    stop(sound: sound)
                }
            }
        }
    }
    
    private func playAndScheduleNext(
        _ sound: Sound,
        _ shouldPlay: Bool = true
    ) {
        
        /*
         */
        
        if shouldPlay {
            play(sound: sound)
        }
        
        /*
         */
        
        if
            let keyValue = audioPCMBuffers.first(where: { (key: Sound, value: AVAudioPCMBuffer) in
                key.soundFileName == sound.soundFileName
            })
        {
            perform(
                #selector(playNextLoop(for:)),
                with: sound,
                afterDelay: keyValue.value.length
            )
        }
    }
    
    /*
     MARK: - Clear
     */
    
    func clear() {
        
        /*
         */
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        /*
         */
        
        displayLink?.invalidate()
        
        /*
         */
        
        let realm = try! Realm()
        try! realm.safeWrite { [weak self] in
            self?.package.sounds.forEach { sound in
                sound.state = .none
            }
        }
        
        /*
         */
        
        audioEngine.mainMixerNode.removeTap(onBus: 0)
        
        /*
         */
        
        audioEngine.attachedNodes.forEach { audioNode in
            if audioNode is AVAudioPlayerNode {
                audioEngine.detach(audioNode)
            }
        }
        
        /*
         */
        
        audioPCMBuffers.removeAll()
        stackLoops.removeAll()
        services.removeAll()
        
        /*
         */
        
        isAutoplayEnabled = false
    }
}
