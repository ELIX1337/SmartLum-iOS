//
//  PeripheralDataModel.swift
//  SmartLum
//
//  Created by ELIX on 18.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import Foundation

/// Модель данных, получаемых с устройства.
/// Здесь описаны такие данные, которые требуют особой кодировки (режим анимации и тд).
protocol PeripheralDataModel {
    var code: Int  { get }
    var name: String { get }
}

/// Это расширение позволяет использовать RawValue enum'а в качестве кода.
extension PeripheralDataModel where Self.RawValue == Int, Self: RawRepresentable {
    var code: Int { return self.rawValue }
}

// Стандартные настройки
/// Режим работы адаптивной яркости
enum PeripheralLedAdaptiveMode: Int, CaseIterable, PeripheralDataModel {
    
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

/// Режим работы лестницы.
/// сенсоры - выключится когда сработает второй сенсор.
/// таймер - выключится по таймеру.
enum PeripheralStairsWorkMode: Int, CaseIterable, PeripheralDataModel {
    
    case bySensors = 0
    case byTimer = 1
    
    var name: String {
        switch self {
        case .bySensors: return "peripheral_stairs_work_mode_by_sensor".localized
        case .byTimer: return "peripheral_stairs_work_mode_by_timer".localized
        }
    }
}

/// Направления анимации
enum PeripheralAnimationDirections: Int, CaseIterable, PeripheralDataModel {
    
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


