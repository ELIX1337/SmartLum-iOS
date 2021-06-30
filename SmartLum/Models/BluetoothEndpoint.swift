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
        case diplom
        
        var uuidString: String {
            switch self {
            case .flClassic: return "BB930001-3CE1-4720-A753-28C0159DC777"
            case .flMini:    return "BB930002-3CE1-4720-A753-28C0159DC777"
            case .diplom:    return "00001523-1212-EFDE-1523-785FEABCD123"
            }
        }
    }
    
    enum Services: CaseIterable {
        case info
        case color
        case animation
        
        case environment
        case distance
        case indication
        
        var uuidString: String {
            switch self {
            case .info:        return "00001526-1212-EFDE-1523-785FEABCD123"
            case .color:       return "BB930B00-3CE1-4720-A753-28C0159DC777"
            case .animation:   return "BB930A00-3CE1-4720-A753-28C0159DC777"
            case .environment: return "00001527-1212-EFDE-1523-785FEABCD123"
            case .distance:    return "00001528-1212-EFDE-1523-785FEABCD123"
            case .indication:  return "00001529-1212-EFDE-1523-785FEABCD123"
            }
        }
    }

    enum Characteristics: CaseIterable {
        case firmwareVersion
        case dfu
        case primaryColor
        case secondaryColor
        case randomColor
        case animationMode
        case animationOnSpeed
        case animationOffSpeed
        case animationDirection
        case animationStep
        
        case distance
        case button
        case led
        case temperature
        case lightness
        
        var uuidString: String {
            switch self {
            case .firmwareVersion:      return "00001530-1212-EFDE-1523-785FEABCD123"
            case .dfu:                  return "BB93FFFD-3CE1-4720-A753-28C0159DC777"
            case .primaryColor:         return "BB930B01-3CE1-4720-A753-28C0159DC777"
            case .secondaryColor:       return "BB930B02-3CE1-4720-A753-28C0159DC777"
            case .randomColor:          return "BB930B03-3CE1-4720-A753-28C0159DC777"
            case .animationMode:        return "BB930A01-3CE1-4720-A753-28C0159DC777"
            case .animationOnSpeed:     return "BB930A02-3CE1-4720-A753-28C0159DC777"
            case .animationOffSpeed:    return "BB930A03-3CE1-4720-A753-28C0159DC777"
            case .animationDirection:   return "BB930A04-3CE1-4720-A753-28C0159DC777"
            case .animationStep:        return "BB930A05-3CE1-4720-A753-28C0159DC777"
                
            case .distance:    return "00001544-1212-EFDE-1523-785FEABCD123"
            case .button:      return "00001524-1212-EFDE-1523-785FEABCD123"
            case .led:         return "00001525-1212-EFDE-1523-785FEABCD123"
            case .temperature: return "00001542-1212-EFDE-1523-785FEABCD123"
            case .lightness:   return "00001533-1212-EFDE-1523-785FEABCD123"
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
