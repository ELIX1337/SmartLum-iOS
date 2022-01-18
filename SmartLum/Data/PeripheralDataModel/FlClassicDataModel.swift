//
//  FlClassicDataModel.swift
//  SmartLum
//
//  Created by ELIX on 18.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import Foundation

/// Анимации устройства FL-Classic
enum FlClassicAnimations: Int, CaseIterable, PeripheralDataModel {
    
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
