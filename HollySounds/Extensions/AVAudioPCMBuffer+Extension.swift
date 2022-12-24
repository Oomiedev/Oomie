//
//  AVAudioPCMBuffer+Extension.swift
//  HollySounds
//
//  Created by Ne Spesha on 8.06.22.
//

import Foundation
import AVFoundation

extension AVAudioPCMBuffer {
    
    var length: TimeInterval {
        let framecount = Double(frameLength)
        let samplerate = format.sampleRate
        return TimeInterval(framecount / samplerate)
    }
    
}
