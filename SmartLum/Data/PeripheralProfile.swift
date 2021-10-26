//
//  PeripheralProfile.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

enum PeripheralProfile {
    
    case FlClassic
    case FlMini
    case SlBase
    
    var uuid: CBUUID {
        switch self {
        case .FlClassic: return UUIDs.TORCHERE_ADVERTISING_UUID
        case .FlMini:    return UUIDs.FL_MINI_ADVERTISING_UUID
        case .SlBase:    return UUIDs.SL_BASE_ADVERTISING_UUID
        }
    }
    
    static func getPeripheralType(uuid: CBUUID) -> Self? {
        switch uuid {
        case UUIDs.TORCHERE_ADVERTISING_UUID: return Self.FlClassic
        case UUIDs.FL_MINI_ADVERTISING_UUID: return Self.FlMini
        case UUIDs.SL_BASE_ADVERTISING_UUID: return Self.SlBase
        default: return nil
        }
    }
    
}