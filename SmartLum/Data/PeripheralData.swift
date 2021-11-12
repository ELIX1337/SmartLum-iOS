//
//  PeripheralData.swift
//  SmartLum
//
//  Created by ELIX on 15.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

protocol PeripheralData {
    
    var values: [String:Any] { get set }
    func getValue(key: String) -> Any?
    mutating func setValue(key: String, value: Any)
}

extension PeripheralData {
    
    func getValue(key: String) -> Any? {
        return values[key]
    }
    
    mutating func setValue(key: String, value: Any) {
        values[key] = value
    }
}

struct BasePeripheralData {
    static var firmwareVersionKey: String { "PeripheralFirmwareVersion" }
    static var initStateKey:       String { "PeripheralInitState" }
    static var errorKey:           String { "PeripheralError" }
    static var errorDetailKey:     String { "PeripheralErrorDetail" }
    static var factoryResetKey:    String { "PeripheralFactoryReset" }
}

struct SlBaseData: PeripheralData {
    var values: [String:Any]
    
    static let topTriggerDistanceKey = "TopTriggerDistanceKey"
    static let botTriggerDistanceKey = "BotTriggerDistanceKey"
    static let ledStateKey           = "LedStateKey"
    static let ledBrightnessKey      = "LedBrightnessKey"
    static let ledTimeout            = "LedTimeoutKey"
    static let animationSpeedKey     = "AnimationSpeedKey"
    
    static let ledMinBrightness = 1
    static let ledMaxBrightness = 100
    static let ledMinTimeout    = 1
    static let ledMaxTimeout    = 120
    static let sensorMinDistance = 20
    static let sensorMaxDistance = 200
    static let animationMinSpeed = 1
    static let animationMaxSpeed = 100
}

struct SlStandartData: PeripheralData {
    var values: [String : Any]
    
    static let primaryColorKey         = "PrimaryColorKey"
    static let ledStateKey             = "LedStateKey"
    static let ledBrightnessKey        = "LedBrightnessKey"
    static let ledTimeoutKey           = "LedTimeoutKey"
    static let topTriggerDistanceKey   = "TopTriggerDistanceKey"
    static let botTriggerDistanceKey   = "BotTriggerDistanceKey"
    static let topLightnessDistanceKey = "TopTriggerDistanceKey"
    static let botLightnessDistanceKey = "BotTriggerDistanceKey"
    static let animationModeKey        = "AnimationModeKey"
    static let animationSpeedKey       = "AnimationSpeedKey"
    static let animationDirectionKey   = "AnimationDirectionKey"

    static let ledMinBrightness = 1
    static let ledMaxBrightness = 255
    static let ledMinTimeout    = 1
    static let ledMaxTimeout    = 120
    static let sensorMinDistance = 20
    static let sensorMaxDistance = 200
    static let animationMinSpeed = 1
    static let animationMaxSpeed = 100

}

struct FlClassicData: PeripheralData {
    var values: [String : Any]
    
    static let primaryColorKey       = "PrimaryColorKey"
    static let secondaryColorKey     = "SecondaryColorKey"
    static let randomColorKey        = "RandomColorKey"
    static let animationModeKey      = "AnimationModeKey"
    static let animationSpeedKey     = "AnimationSpeedKey"
    static let animationDirectionKey = "AnimationDirectionKey"
    static let animationStepKey      = "AnimationStepKey"
    
    static let animationMinSpeed = 0
    static let animationMaxSpeed = 30
    static let animationMinStep  = 1
    static let animationMaxStep  = 10
}

protocol PeripheralDataElement {
    var code: Int  { get }
    var name: String { get }
}

enum PeripheralAnimations: Int, CaseIterable, PeripheralDataElement {
    
    case tetris             = 1
    case wave               = 2
    case transfusion        = 3
    case rainbowTransfusion = 4
    case rainbow            = 5
    case `static`           = 6

    var name: String {
        switch self {
        case .tetris:             return "peripheral_animation_mode_tetris".localized
        case .wave:               return "peripheral_animation_mode_wave".localized
        case .transfusion:        return "peripheral_animation_mode_transfusion".localized
        case .rainbowTransfusion: return "peripheral_animation_mode_rainbow_transfusion".localized
        case .rainbow:            return "peripheral_animation_mode_rainbow".localized
        case .static:             return "peripheral_animation_mode_static".localized
        }
    }
    var code: Int {{ return self.rawValue }()}
}

enum PeripheralAnimationDirections: Int, CaseIterable, PeripheralDataElement {
    
    case fromBottom = 1
    case fromTop    = 2
    case toCenter   = 3
    case fromCenter = 4
    
    var name: String {
        switch self {
        case .fromBottom: return "peripheral_animation_direction_from_bottom".localized
        case .fromTop:    return "peripheral_animation_direction_from_top".localized
        case .toCenter:   return "peripheral_animation_direction_to_center".localized
        case .fromCenter: return "peripheral_animation_direction_from_center".localized
        }
    }
    
    var code: Int {{ return self.rawValue }()}
}

enum PeripheralError: Int, CaseIterable, PeripheralDataElement {
    
    case error1 = 0x01
    case error2 = 0x02
    
    var name: String {
        switch self {
        case .error1: return "Error 1"
        case .error2: return "Error 2"
        }
    }
    
    var code: Int {{ return self.rawValue }()}
    
    var description: String {
        switch self {
        case .error1: return "peripheral_error_code_1_description".localized
        case .error2: return "peripheral_error_code_2_description".localized
        }
    }

}
