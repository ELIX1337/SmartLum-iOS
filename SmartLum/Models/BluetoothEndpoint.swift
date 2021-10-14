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
    
    enum Services: CaseIterable {
        case info
        case color
        case animation
        case led
        case sensor
        case event
        
        var uuidString: String {
            switch self {
            case .info:        return UUIDs.DEVICE_INFO_SERVICE_UUID.uuidString
            case .color:       return UUIDs.COLOR_SERVICE_UUID.uuidString
            case .animation:   return UUIDs.ANIMATION_SERVICE_UUID.uuidString
            case .led:         return UUIDs.LED_SERVICE_UUID.uuidString
            case .sensor:      return UUIDs.SENSOR_SERVICE_UUID.uuidString
            case .event:       return UUIDs.EVENT_SERVICE_UUID.uuidString
            }
        }
    }

    enum Characteristics: CaseIterable {
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
        
        var uuidString: String {
            switch self {
            case .firmwareVersion:      return UUIDs.DEVICE_FIRMWARE_VERSION_CHARACTERISTIC_UUID.uuidString
            case .factorySettings:      return UUIDs.FACTORY_SETTINGS_CHARACTERISTIC_UUID.uuidString
            case .initState:            return UUIDs.DEVICE_INIT_STATE_CHARACTERISTIC_UUID.uuidString
            case .dfu:                  return UUIDs.DEVICE_DFU_CHARACTERISTIC_UUID.uuidString
            case .error:                return UUIDs.EVENT_ERROR_CHARACTERISTIC_UUID.uuidString
            case .primaryColor:         return UUIDs.COLOR_PRIMARY_CHARACTERISTIC_UUID.uuidString
            case .secondaryColor:       return UUIDs.COLOR_SECONDARY_CHARACTERISTIC_UUID.uuidString
            case .randomColor:          return UUIDs.COLOR_RANDOM_CHARACTERISTIC_UUID.uuidString
            case .animationMode:        return UUIDs.ANIMATION_MODE_CHARACTERISTIC_UUID.uuidString
            case .animationOnSpeed:     return UUIDs.ANIMATION_ON_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationOffSpeed:    return UUIDs.ANIMATION_OFF_SPEED_CHARACTERISTIC_UUID.uuidString
            case .animationDirection:   return UUIDs.ANIMATION_DIRECTION_CHARACTERISTIC_UUID.uuidString
            case .animationStep:        return UUIDs.ANIMATION_STEP_CHARACTERISTIC_UUID.uuidString
            case .topSensorTriggerDistance: return UUIDs.TOP_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            case .botSensorTriggerDistance: return UUIDs.BOT_SENSOR_TRIGGER_DISTANCE_CHARACTERISTIC_UUID.uuidString
            }
        }
    }

    static func getCases(_ service: CBService, _ characteristic: CBCharacteristic) -> [Services:Characteristics]? {
        guard let s = Services.allCases.filter({ $0.uuidString == service.uuid.uuidString }).first else { return nil }
        guard let c = Characteristics.allCases.filter({ $0.uuidString == characteristic.uuid.uuidString }).first else { return nil }
        return [s:c]
    }
    
    static func getCharacteristic(characteristic: CBCharacteristic) -> Characteristics? {
        guard let c = Characteristics.allCases.filter({ $0.uuidString == characteristic.uuid.uuidString }).first else { return nil }
        return c
    }
    
    static func getService(_ service: CBService) -> Services? {
        guard let s = Services.allCases.filter({ $0.uuidString == service.uuid.uuidString }).first else { return nil }
        return s
    }
}
