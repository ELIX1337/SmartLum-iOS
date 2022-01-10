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

struct StairsControllerData: PeripheralData {
    var values: [String : Any]
    
    static let primaryColorKey        = "PrimaryColorKey"
    static let randomColorKey         = "RandomColorKey"
    static let ledStateKey            = "LedStateKey"
    static let ledBrightnessKey       = "LedBrightnessKey"
    static let ledTimeoutKey          = "LedTimeoutKey"
    static let controllerTypeKey      = "ControllerTypeKey"
    static let ledAdaptiveModeKey     = "LedAdaptiveModeKey"
    static let topTriggerDistanceKey  = "TopTriggerDistanceKey"
    static let botTriggerDistanceKey  = "BotTriggerDistanceKey"
    static let topTriggerLightnessKey = "TopTriggerDistanceKey"
    static let botTriggerLightnessKey = "BotTriggerDistanceKey"
    static let topCurrentDistanceKey  = "TopCurrentDistanceKey"
    static let botCurrentDistanceKey  = "BotCurrentDistanceKey"
    static let topCurrentLightnessKey = "TopCurrentLightnessKey"
    static let botCurrentLightnessKey = "BotCurrentLightnessKey"
    static let animationModeKey       = "AnimationModeKey"
    static let animationSpeedKey      = "AnimationSpeedKey"
    static let animationDirectionKey  = "AnimationDirectionKey"
    static let stepsCountKey          = "StepsCountKey"
    static let standbyStateKey        = "StandbyStateKey"
    static let standbyBrightnessKey   = "StandbyBrightnessKey"
    static let standbyTopCountKey     = "StandbyTopCountKey"
    static let standbyBotCountKey     = "StandbyBotCountKey"
    static let stairsWorkModeKey      = "StairsWorkMode"
    static let topSensorCountKey      = "TopSensorCountKey"
    static let botSensorCountKey      = "BotSensorCountKey"
    
    static let slBaseLedMinBrightness = 1
    static let slBaseLedMaxBrightness = 100
    static let slBaseLedMinTimeout    = 1
    static let slBaseLedMaxTimeout    = 120
    static let slBaseSensorMinDistance = 20
    static let slBaseSensorMaxDistance = 200
    static let slBaseAnimationMinSpeed = 1
    static let slBaseAnimationMaxSpeed = 100

    static let slProLedMinBrightness  = 1
    static let slProLedMaxBrightness  = 255
    static let slProLedMinTimeout     = 1
    static let slProLedMaxTimeout     = 120
    static let slProSensorMinDistance = 20
    static let slProSensorMaxDistance = 200
    static let slProAnimationMinSpeed = 1
    static let slProAnimationMaxSpeed = 100
    static let slProStepsMinCount     = 2
    static let slProStepsMaxCount     = 26
    static let slProSensorMinCount    = 1
    static let slProSensorMaxCount    = 2
    static let slProStandbyMinCount   = 1
    static let slProStandbyMaxCount   = slProStepsMaxCount / 2
    
    static let slStandartLedMinBrightness  = 1
    static let slStandartLedMaxBrightness  = 255
    static let slStandartLedMinTimeout     = 1
    static let slStandartLedMaxTimeout     = 120
    static let slStandartSensorMinDistance = 20
    static let slStandartSensorMaxDistance = 200
    static let slStandartAnimationMinSpeed = 1
    static let slStandartAnimationMaxSpeed = 100
    static let slStandartStepsMinCount     = 2
    static let slStandartStepsMaxCount     = 26
    static let slStandartSensorMinCount    = 1
    static let slStandartSensorMaxCount    = 2
    static let slStandartStandbyMinCount   = 1
    static let slStandartStandbyMaxCount   = slStandartStepsMaxCount / 2

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

extension PeripheralDataElement where Self.RawValue == Int, Self: RawRepresentable {
    var code: Int { return self.rawValue }
}

enum SlProControllerType: Int, CaseIterable, PeripheralDataElement {
       
    case `default` = 0
    case rgb = 1
    
    var name: String {
        switch self {
        case .`default`: return "peripheral_sl_pro_controller_type_default".localized
        case .rgb:       return "peripheral_sl_pro_controller_type_rgb".localized
        }
    }
    
}

enum PeripheralLedAdaptiveMode: Int, CaseIterable, PeripheralDataElement {
    
    case off = 0
    case top = 1
    case bot = 2
    case average = 3
        
    var name: String {
        switch self {
        case .off: return "peripheral_adaptime_mode_off".localized
        case .top: return "peripheral_adaptime_mode_top".localized
        case .bot: return "peripheral_adaptime_mode_bot".localized
        case .average: return "peripheral_adaptime_mode_average".localized
        }
    }
}

enum PeripheralStairsWorkMode: Int, CaseIterable, PeripheralDataElement {
    
    case bySensors = 0
    case byTimer = 1
    
    var name: String {
        switch self {
        case .bySensors: return "peripheral_stairs_work_mode_by_sensor".localized
        case .byTimer: return "peripheral_stairs_work_mode_by_timer".localized
        }
    }
}

enum SlProAnimations: Int, CaseIterable, PeripheralDataElement {
    
    //case tetris
    case off        = 0
    case stepByStep = 1
    case sharp      = 2
    
    var name: String {
        switch self {
        case .off:          return "sl_pro_animations_off".localized
        case .stepByStep:   return "sl_pro_animations_stepByStep".localized
        case .sharp:        return "sl_pro_animations_sharp".localized
        }
    }
}

enum FlClassicAnimations: Int, CaseIterable, PeripheralDataElement {
    
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
        
    var description: String {
        switch self {
        case .error1: return "peripheral_error_code_1_description".localized
        case .error2: return "peripheral_error_code_2_description".localized
        }
    }

}
