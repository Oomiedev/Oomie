//
//  Sound.swift
//  HollySounds
//
//  Created by Ne Spesha on 20.04.22.
//

import Foundation
import RealmSwift
import AVFoundation
import UIKit

/*
 MARK: -
 */

enum Note: Int, PersistableEnum {
    
    case C,
         CSharp,
         D,
         DSharp,
         E,
         F,
         FSharp,
         G,
         GSharp,
         A,
         ASharp,
         B
    
    var stringValue: String? {
        let map: [Note: String] = [
            .C: "C",
            .CSharp: "C#",
            .D: "D",
            .DSharp: "D#",
            .E: "E",
            .F: "F",
            .FSharp: "F#",
            .G: "G",
            .GSharp: "G#",
            .A: "A",
            .ASharp: "A#",
            .B: "B",
        ]

        return map[self]
    }
    
    func getNoteNumber(for octave: Int) -> Int? {
        let C1 = 24
        return (C1 + self.rawValue) + 12 * (octave - 1)
    }
}

enum Ambience: Int, PersistableEnum {
    
    case Main1,
         Main2,
         Main3,
         Main4,
         Secondary1,
         Secondary2,
         Secondary3,
         Thirdly1,
         Thirdly2,
         Thirdly3
    
    var stringValue: String? {
        let map: [Ambience: String] = [
            .Main1: "1-1 PAD 1",
            .Main2: "1-1 PAD 2",
            .Main3: "1-1 PAD 3",
            .Main4: "1-1 PAD 4",
            .Secondary1: "2-1 PAD 2",
            .Secondary2: "2-1 PAD 1",
            .Secondary3: "2-1 PAD 3",
            .Thirdly1: "3-1 PAD 2",
            .Thirdly2: "3-1 PAD 1",
            .Thirdly3: "3-1 PAD 3"
        ]
        
        return map[self]
    }
    
    var loopType: SoundType? {
        let map: [Ambience: SoundType] = [
            .Main1: .loop1,
            .Main2: .loop1,
            .Main3: .loop1,
            .Main4: .loop1,
            .Secondary1: .loop2,
            .Secondary2: .loop2,
            .Secondary3: .loop2,
            .Thirdly1: .loop3,
            .Thirdly2: .loop3,
            .Thirdly3: .loop3,
        ]
        
        return map[self]
    }
    
    var index: Int {
        let map: [Ambience: Int] = [
            .Main1: 0,
            .Main2: 1,
            .Main3: 2,
            .Main4: 3,
            .Secondary1: 0,
            .Secondary2: 1,
            .Secondary3: 2,
            .Thirdly1: 0,
            .Thirdly2: 1,
            .Thirdly3: 2
        ]
        
        return map[self] ?? 0
    }
}

@objc
enum SoundType: Int, PersistableEnum {
    
    case single,
         loop1,
         loop2,
         loop3
    
    var color: UIColor? {
        let map: [SoundType: String] = [
            .single: "Color 2",
            .loop1: "Color 2",
            .loop2: "Color 2",
            .loop3: "Color 2"
        ]
        
        if let value = map[self] {
            return UIColor(named: value)
        }
        
        return UIColor(named: "Color 2")
    }
    
    var lineDashPattern: [NSNumber] {
        let map: [SoundType: [NSNumber]] = [
            .single: [1, 0],
            .loop1: [1, 0],
            .loop2: [3, 3],
            .loop3: [3, 3]
        ]
        
        if let value = map[self] {
            return value
        }
        
        return [1, 0]
    }
}

enum SoundState: Int, PersistableEnum {
    case none, playing
}

final class Sound: Object {
    
    /*
     MARK: -
     */
    
    @Persisted
    var type: SoundType = .single
    
    @Persisted
    var state: SoundState = .none
    
    @Persisted
    var soundFileName: String!
    
    /*
     MIDI Note Number.
     */
    
    @Persisted
    var noteNumber: Int = 0
    
    /*
     Next infex for autoplay.
     */
    
    @Persisted
    var index: Int = 0
    
    @Persisted
    var duration: Double = 0
}
