//
//  BluetoothEndpoint.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol StringToUUID {
    var uuidString: String { get }
    var uuid: CBUUID { get }
}

extension StringToUUID {
    var uuid: CBUUID { get { return CBUUID.init(string: uuidString) }}
}

struct BluetoothEndpoint {
    
    enum AdvertisingServices: CaseIterable, StringToUUID {
        case flClassic
        case flMini
        case slBase
        
        var uuidString: String {
            switch self {
            case .flClassic: return UUIDs.TORCHERE_ADVERTISING_UUID.uuidString
            case .flMini:    return UUIDs.FL_MINI_ADVERTISING_UUID.uuidString
            case .slBase:    return UUIDs.SL_BASE_ADVERTISING_UUID.uuidString
            }
        }
    }
    
    enum Service: CaseIterable {
        case info
        case color
        case animation
        case led
        case sensor
        case event
        
        var uuidString: String {
            switch self {
            case .info:      return UUIDs.DEVICE_INFO_SERVICE_UUID.uuidString
            case .color:     return UUIDs.COLOR_SERVICE_UUID.uuidString
            case .animation: return UUIDs.ANIMATION_SERVICE_UUID.uuidString
            case .led:       return UUIDs.LED_SERVICE_UUID.uuidString
            case .sensor:    return UUIDs.SENSOR_SERVICE_UUID.uuidString
            case .event:     return UUIDs.EVENT_SERVICE_UUID.uuidString
            }
        }
        
        func uuidString(legacy: Bool) -> String {
            switch self {
            case .info:
                return legacy ? UUIDs.Legacy.DEVICE_INFO_SERVICE_UUID.uuidString :
                                UUIDs.DEVICE_INFO_SERVICE_UUID.uuidString
            case .color:
                return legacy ? UUIDs.Legacy.COLOR_SERVICE_UUID.uuidString :
                                UUIDs.COLOR_SERVICE_UUID.uuidString
            case .animation:
                return legacy ? UUIDs.Legacy.ANIMATION_SERVICE_UUID.uuidString :
                                UUIDs.ANIMATION_SERVICE_UUID.uuidString
            case .led:
                return legacy ? UUIDs.Legacy.LED_SERVICE_UUID.uuidString :
                                UUIDs.LED_SERVICE_UUID.uuidString
            case .sensor:
                return legacy ? UUIDs.Legacy.SENSOR_SERVICE_UUID.uuidString :
                                UUIDs.SENSOR_SERVICE_UUID.uuidString
            case .event:
                return legacy ? UUIDs.Legacy.EVENT_SERVICE_UUID.uuidString :
                                UUIDs.EVENT_SERVICE_UUID.uuidString
            }
        }
    }
    
    enum Characteristic: CaseIterable {
        case firmwareVersion
        case factorySettings
        case initState
        case dfu
        case error
        case primaryColor
        case secondaryColor
        case randomColor
        case animationMode
        case animationOnSpeed
        case animationOffSpeed
        case animationDirection
        case animationStep
        case topSensorTriggerDistance
        case botSensorTriggerDistance
        case ledState
        case ledBrightness
        case ledTimeout
        
        var uuidString: String {
            switch self {
            case .firmwareVersion:          return UUIDs.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID.uuidString
            case .factorySettings:          return UUIDs.FACTORY_SETTINGS_CHARACTERISTIC_UUID.uuidString
            case .initState:                return UUIDs.DEVICE_INIT_STATE_CHARACTERISTIC_UUID.uuidString
            case .dfu:                      return UUIDs.DEVICE_DFU_CHARACTERISTIC_UUID.uuidString
            case .error:                    return UUIDs.EVENT_ERROR_CHARACTERISTIC_UUID.uuidString
            case .primaryColor:             return UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID.uuidString
            case .secondaryColor:           return UUIDs.COLOR_SECONDARY_CHARACTERISTIC_UUID.uuidString
            case .randomColor:              return UUIDs.COLOR_RANDOM_CHARACTERISTIC_UUID.uuidString
            case .animationMode:            return UUIDs.ANIMATION_MODE_CHARACTERISTIC_UUID.uuidString
            case .animationOnSpeed:         return UUIDs.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationOffSpeed:        return UUIDs.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationDirection:       return UUIDs.ANIMATION_DIRECTION_CHARACTERISTIC_UUID.uuidString
            case .animationStep:            return UUIDs.ANIMATION_STEP_CHARACTERISTIC_UUID.uuidString
            case .topSensorTriggerDistance: return UUIDs.TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            case .botSensorTriggerDistance: return UUIDs.BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            case .ledState:                 return UUIDs.LED_STATE_CHARACTERISTIC_UUID.uuidString
            case .ledBrightness:            return UUIDs.LED_BRIGHTNESS_CHARACTERISTIC_UUID.uuidString
            case .ledTimeout:               return UUIDs.LED_TIMEOUT_CHARACTERISTIC_UUID.uuidString
            }
        }
        
        func uuidString(legacy: Bool) -> String {
            switch self {
            case .firmwareVersion:
                return legacy ? UUIDs.Legacy.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID.uuidString
            case .factorySettings:
                return legacy ? UUIDs.Legacy.FACTORY_SETTINGS_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.FACTORY_SETTINGS_CHARACTERISTIC_UUID.uuidString
            case .initState:
                return legacy ? UUIDs.Legacy.DEVICE_INIT_STATE_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.DEVICE_INIT_STATE_CHARACTERISTIC_UUID.uuidString
            case .dfu:
                return legacy ? UUIDs.Legacy.DEVICE_DFU_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.DEVICE_DFU_CHARACTERISTIC_UUID.uuidString
            case .error:
                return legacy ? UUIDs.Legacy.EVENT_ERROR_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.EVENT_ERROR_CHARACTERISTIC_UUID.uuidString
            case .primaryColor:
                return legacy ? UUIDs.Legacy.COLOR_PRIMARY_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID.uuidString
            case .secondaryColor:
                return legacy ? UUIDs.Legacy.COLOR_SECONDARY_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.COLOR_SECONDARY_CHARACTERISTIC_UUID.uuidString
            case .randomColor:
                return legacy ? UUIDs.Legacy.COLOR_RANDOM_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.COLOR_RANDOM_CHARACTERISTIC_UUID.uuidString
            case .animationMode:
                return legacy ? UUIDs.Legacy.ANIMATION_MODE_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.ANIMATION_MODE_CHARACTERISTIC_UUID.uuidString
            case .animationOnSpeed:
                return legacy ? UUIDs.Legacy.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationOffSpeed:
                return legacy ? UUIDs.Legacy.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationDirection:
                return legacy ? UUIDs.Legacy.ANIMATION_DIRECTION_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.ANIMATION_DIRECTION_CHARACTERISTIC_UUID.uuidString
            case .animationStep:
                return legacy ? UUIDs.Legacy.ANIMATION_STEP_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.ANIMATION_STEP_CHARACTERISTIC_UUID.uuidString
            case .topSensorTriggerDistance:
                return legacy ? UUIDs.Legacy.TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            case .botSensorTriggerDistance:
                return legacy ? UUIDs.Legacy.BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            case .ledState:
                return legacy ? UUIDs.Legacy.LED_STATE_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.LED_STATE_CHARACTERISTIC_UUID.uuidString
            case .ledBrightness:
                return legacy ? UUIDs.Legacy.LED_BRIGHTNESS_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.LED_BRIGHTNESS_CHARACTERISTIC_UUID.uuidString
            case .ledTimeout:
                return legacy ? UUIDs.Legacy.LED_TIMEOUT_CHARACTERISTIC_UUID.uuidString :
                                UUIDs.LED_TIMEOUT_CHARACTERISTIC_UUID.uuidString
            }
        }
    }
    
    static func getCases(_ service: CBService, _ characteristic: CBCharacteristic) -> [Service:Characteristic]? {
        var serv = Service.allCases.filter({ $0.uuidString(legacy: false) == service.uuid.uuidString }).first
        if serv == nil {
            serv = Service.allCases.filter({ $0.uuidString(legacy: true) == service.uuid.uuidString }).first
        }
        var char = Characteristic.allCases.filter({ $0.uuidString(legacy: false) == characteristic.uuid.uuidString }).first
        if char == nil {
            char = Characteristic.allCases.filter({ $0.uuidString(legacy: true) == characteristic.uuid.uuidString }).first
        }
        guard
            let s = serv,
            let c = char
        else { return nil }
        return [s:c]
    }
    
    static func getCharacteristic(characteristic: CBCharacteristic) -> Characteristic? {
        var char = Characteristic.allCases.filter({ $0.uuidString(legacy: false) == characteristic.uuid.uuidString }).first
        if char == nil {
            char = Characteristic.allCases.filter({ $0.uuidString(legacy: true) == characteristic.uuid.uuidString }).first
        }
        guard let c = char else { return nil }
        return c
    }
    
    static func getService(_ service: CBService) -> Service? {
        var serv = Service.allCases.filter({ $0.uuidString(legacy: false) == service.uuid.uuidString }).first
        if serv == nil {
            serv = Service.allCases.filter({ $0.uuidString(legacy: true) == service.uuid.uuidString }).first
        }
        guard let s = serv else { return nil }
        return s
    }
}
