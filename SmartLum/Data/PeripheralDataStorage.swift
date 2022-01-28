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
    
    var values: [String : Any] { get set }
    
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

struct PeripheralData: PeripheralDataStorage {
    
    var values: [String : Any] = [:]
    
    var peripheralType: PeripheralProfile
    
    static let primaryColorKey        = "PrimaryColorKey"
    static let secondaryColorKey      = "SecondaryColorKey"
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
    static let animationStepKey       = "AnimationStepKey"
    static let stepsCountKey          = "StepsCountKey"
    static let standbyStateKey        = "StandbyStateKey"
    static let standbyBrightnessKey   = "StandbyBrightnessKey"
    static let standbyTopCountKey     = "StandbyTopCountKey"
    static let standbyBotCountKey     = "StandbyBotCountKey"
    static let stairsWorkModeKey      = "StairsWorkMode"
    static let topSensorCountKey      = "TopSensorCountKey"
    static let botSensorCountKey      = "BotSensorCountKey"
    
    // Диапазон поддерживаемых данных у различных устройств
    
    /// Значения яркости светодиодной ленты.
    var ledBrightness : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1, 1) // Настройка не поддерживается устройством
        case .SlBase:     return (1, 100)
        case .SLStandart: return (1, 255)
        case .SlPro:      return (1, 255)
        }
    }
    
    /// Значения таймаута отключения подстветки.
    var ledTimeout : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1, 1) // Настройка не поддерживается устройством
        case .SlBase:     return (1, 120)
        case .SLStandart: return (1, 120)
        case .SlPro:      return (1, 120)
        }
    }
    
    /// Значения диапазона работы датчиков расстояния.
    var sensorDistance : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1 , 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1 , 1) // Настройка не поддерживается устройством
        case .SlBase:     return (20, 200)
        case .SLStandart: return (20, 200)
        case .SlPro:      return (20, 200)
        }
    }
    
    /// Значения скорости анимации.
    var animationSpeed : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (0, 30)
        case .FlMini:     return (0, 30)
        case .SlBase:     return (1, 100)
        case .SLStandart: return (1, 255)
        case .SlPro:      return (1, 255)
        }
    }
    
    /// Значения шага  анимации.
    var animationStep : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 10)
        case .FlMini:     return (1, 10)
        case .SlBase:     return (1, 1) // Настройка не поддерживается устройством
        case .SLStandart: return (1, 1) // Настройка не поддерживается устройством
        case .SlPro:      return (1, 1) // Настройка не поддерживается устройством
        }
    }
    
    /// Значения количества ступеней
    var stepsCount : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1, 1) // Настройка не поддерживается устройством
        case .SlBase:     return (1, 1) // Настройка не поддерживается устройством
        case .SLStandart: return (2, 18)
        case .SlPro:      return (2, 24)
        }
    }
    
    /// Значения количества сенсоров на ОДИН пролет
    var sensorCount : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1, 1) // Настройка не поддерживается устройством
        case .SlBase:     return (1, 1) // Настройка не поддерживается устройством
        case .SLStandart: return (1, 1)
        case .SlPro:      return (1, 2)
        }
    }
    
    /// Значения количества ступеней дежурной подсветки
    var standbyСount : (min: Int, max: Int) {
        switch peripheralType {
        case .FlClassic:  return (1, 1) // Настройка не поддерживается устройством
        case .FlMini:     return (1, 1) // Настройка не поддерживается устройством
        case .SlBase:     return (1, 1) // Настройка не поддерживается устройством
        case .SLStandart: return (1, stepsCount.max / 2)
        case .SlPro:      return (1, stepsCount.max / 2)
        }
    }
    
}
