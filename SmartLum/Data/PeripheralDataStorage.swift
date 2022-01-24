//
//  PeripheralDataStorage.swift
//  SmartLum
//
//  Created by ELIX on 15.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

/// Костыль, но работает.
/// Данные с устройства хранятся в виде ключ-значений в переменной values.
/// Для удобства реализованы методы getValue и setValue.
/// Ключи из этой коллекции присваиваются ключам CellModel (реализовано во ViewModel устройств).
/// Когда происходит обновление tableView, CellModel по свему ключу находит нужное значение и рисует UI.
/// Обновлять значения тут нужно при получении данных с устройства и при записи на устройство.
protocol PeripheralDataStorage {
    
    var values: [String:Any] { get set }
    func getValue(key: String) -> Any?
    mutating func setValue(key: String, value: Any)
}

extension PeripheralDataStorage {
    
    func getValue(key: String) -> Any? {
        return values[key]
    }
    
    mutating func setValue(key: String, value: Any) {
        values[key] = value
    }
}

/// Стандартные данные, которые есть на всех устройствах
struct BasePeripheralData {
    static var firmwareVersionKey: String { "PeripheralFirmwareVersion" }
    static var initStateKey:       String { "PeripheralInitState" }
    static var errorKey:           String { "PeripheralError" }
    static var errorDetailKey:     String { "PeripheralErrorDetail" }
    static var factoryResetKey:    String { "PeripheralFactoryReset" }
}

/// Данные присущие устройствам SL-Base, SL-Pro, SL-Standart.
struct StairsControllerData: PeripheralDataStorage {
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
    static let topTriggerLightnessKey = "TopTriggerLightnessKey"
    static let botTriggerLightnessKey = "BotTriggerLightnessKey"
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
    
    // Тут описано, какие значения могут принимать те или иные настройки устройства SL-Base.
    static let slBaseLedMinBrightness = 1
    static let slBaseLedMaxBrightness = 100
    static let slBaseLedMinTimeout    = 1
    static let slBaseLedMaxTimeout    = 120
    static let slBaseSensorMinDistance = 20
    static let slBaseSensorMaxDistance = 200
    static let slBaseAnimationMinSpeed = 1
    static let slBaseAnimationMaxSpeed = 100

    // Тут описано, какие значения могут принимать те или иные настройки устройства SL-Pro.
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
    
    // Тут описано, какие значения могут принимать те или иные настройки устройства SL-Standart.
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

/// Данные для устройства FL-Classic
struct FlClassicData: PeripheralDataStorage {
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

