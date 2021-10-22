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
    
    static let ledMinBrightness = 0
    static let ledMaxBrightness = 100
    static let ledMinTimeout    = 0
    static let ledMaxTimeout    = 10
    static let sensorMinDistance = 1
    static let sensorMaxDistance = 200
    static let animationMinSpeed = 1
    static let animationMaxSpeed = 10
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

//struct PeripheralDataModel {
//
//    var isInitialized: Bool?
//    var firmwareVersion: Int?
//    var errorCode: Int?
//
//    var animationOnSpeed:  (value: Int?, minValue: Int?, maxValue: Int?)
//    var animationOffSpeed: (value: Int?, minValue: Int?, maxValue: Int?)
//    var animationStep:     (value: Int?, minValue: Int?, maxValue: Int?)
//    var ledTimeout:        (value: Int?, minValue: Int?, maxValue: Int?)
//    var ledBrightness:     (value: Int?, minValue: Int?, maxValue: Int?)
//    var topSensorTriggerDistance: (value: Int?, minValue: Int?, maxValue: Int?)
//    var botSensorTriggerDistance: (value: Int?, minValue: Int?, maxValue: Int?)
//
//    var primaryColor:       UIColor?
//    var secondaryColor:     UIColor?
//    var randomColor:        Bool?
//    var animationMode:      PeripheralAnimations?
//    var animationDirection: PeripheralAnimationDirections?
//
//    var ledState: Bool?
//}

protocol PeripheralDataElement {
    var code: UInt8  { get }
    var name: String { get }
}

enum PeripheralAnimations: UInt8, CaseIterable, PeripheralDataElement {
    
    case tetris             = 1
    case wave               = 2
    case transfusion        = 3
    case rainbowTransfusion = 4
    case rainbow            = 5
    case `static`           = 6

    var name: String {
        switch self {
        case .tetris:               return "Tetris"
        case .wave:                 return "Wave"
        case .transfusion:          return "Transfusion"
        case .rainbowTransfusion:   return "Rainbow transfusion"
        case .rainbow:              return "Rainbow"
        case .static:               return "Static"
        }
    }
    var code: UInt8 {{ return self.rawValue }()}
}

enum PeripheralAnimationDirections: UInt8, CaseIterable, PeripheralDataElement {
    
    case fromBottom = 1
    case fromTop    = 2
    case toCenter   = 3
    case fromCenter = 4
    
    var name: String {
        switch self {
        case .fromBottom: return "From bottom"
        case .fromTop:    return "From top"
        case .toCenter:   return "To center"
        case .fromCenter: return "From center"
        }
    }
    
    var code: UInt8 {{ return self.rawValue }()}
}
