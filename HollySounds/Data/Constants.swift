//
//  Constants.swift
//  HollySounds
//
//  Created by Ne Spesha on 10.04.22.
//

import Foundation
import DeviceKit

public var SizeFactor: CGFloat {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return 1.3
    }

    return ((Device.current.diagonal == Device.iPhoneX.diagonal || Device.current.diagonal == Device.iPhoneXS.diagonal || Device.current.diagonal == Device.iPhoneXSMax.diagonal || Device.current.diagonal == Device.iPhoneXR.diagonal || Device.current.diagonal == Device.iPhone11.diagonal || Device.current.diagonal == Device.iPhone11Pro.diagonal || Device.current.diagonal == Device.iPhone11ProMax.diagonal) || Device.current.diagonal == Device.iPhoneSE2.diagonal || Device.current.diagonal == Device.iPhone12Mini.diagonal || Device.current.diagonal == Device.iPhone12.diagonal || Device.current.diagonal == Device.iPhone12Pro.diagonal || Device.current.diagonal == Device.iPhone12ProMax.diagonal || Device.current.diagonal == Device.iPhone13Mini.diagonal || Device.current.diagonal == Device.iPhone13.diagonal || Device.current.diagonal == Device.iPhone13Pro.diagonal || Device.current.diagonal == Device.iPhone13ProMax.diagonal ? UIScreen.main.bounds.width / 390 : UIScreen.main.bounds.height / 667)
}

let TouchPadViewSize = CGSize(
    width: 100 * SizeFactor,
    height: 100 * SizeFactor
)

let FadeLength: Double = 10
let FadeStep: Float = 0.002
let LoopsStartRange: ClosedRange<Double> = 0...10
let LoopsSwitchRange: ClosedRange<Double> = 60...120

let OffsetX: CGFloat = 110 * SizeFactor
let OffsetY: CGFloat = 120 * SizeFactor

let AnimationDurationLoop: Double = 10
let AnimationDurationSample: Double = 3
