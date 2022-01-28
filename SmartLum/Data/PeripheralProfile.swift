//
//  PeripheralProfile.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import Foundation
import CoreBluetooth

/// Enum для определения типа устройства.
/// А вообще куча методов для получения соответсвующих классов и тд в зависимости от устройства.
/// Какой-то говнокод за 15 минут.
enum PeripheralProfile {
    
    case FlClassic
    case FlMini
    case SlBase
    case SLStandart
    case SlPro
    
    var uuid: CBUUID {
        switch self {
        case .FlClassic:  return UUIDs.FL_CLASSIC_ADVERTISING_UUID
        case .FlMini:     return UUIDs.FL_MINI_ADVERTISING_UUID
        case .SlBase:     return UUIDs.SL_BASE_ADVERTISING_UUID
        case .SLStandart: return UUIDs.SL_STANDART_ADVERTISING_UUID
        case .SlPro:      return UUIDs.SL_PRO_ADVERTISING_UUID
        }
    }
    
    /// Определяет тип устройства по рекламному UUID
    static func getPeripheralProfile(uuid: CBUUID) -> Self? {
        switch uuid {
        case UUIDs.FL_CLASSIC_ADVERTISING_UUID:  return Self.FlClassic
        case UUIDs.FL_MINI_ADVERTISING_UUID:     return Self.FlMini
        case UUIDs.SL_BASE_ADVERTISING_UUID:     return Self.SlBase
        case UUIDs.SL_STANDART_ADVERTISING_UUID: return Self.SLStandart
        case UUIDs.SL_PRO_ADVERTISING_UUID:      return Self.SlPro
        default: return nil
        }
    }
    
    /// Возвоащает нужный класс Peripheral.
    func getPeripheralType(peripheral: CBPeripheral, manager: CBCentralManager) -> BasePeripheral {
        switch self {
        case .FlClassic:  return FlClassicPeripheral.init(peripheral, manager)
        case .FlMini:     return FlClassicPeripheral.init(peripheral, manager)
        case .SlBase:     return SlBasePeripheral.init(peripheral, manager)
        case .SLStandart: return SlProStandartPeripheral.init(peripheral, manager)
        case .SlPro:      return SlProStandartPeripheral.init(peripheral, manager)
        }
    }
    
    /// Вернет соответсвующий ViewController для устройства
    /// Очевидно, что костыль
    static func getPeripheralVC(peripheral: PeripheralProfile) -> PeripheralViewControllerProtocol {
        switch peripheral {
        case .FlClassic:  return FlClassicViewController()
        case .FlMini:     return FlClassicViewController()
        case .SlBase:     return SlBaseViewController()
        case .SLStandart: return SlProStandartViewController()
        case .SlPro:      return SlProStandartViewController()
        }
    }
    
}
