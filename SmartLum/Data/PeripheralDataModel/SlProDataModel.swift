//
//  SlProDataModel.swift
//  SmartLum
//
//  Created by ELIX on 18.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import Foundation

/// Тип контроллеров SL-Pro и SL-Standart (одноцветный или многоцветный).
enum SlProStandartControllerType: Int, CaseIterable, PeripheralDataModel {
       
    case `default` = 0
    case rgb = 1
    
    var name: String {
        switch self {
        case .`default`: return "peripheral_sl_pro_controller_type_default".localized
        case .rgb:       return "peripheral_sl_pro_controller_type_rgb".localized
        }
    }
    
}

/// Анимации устройств SL-Pro и SL-Standart
enum SlProStandartAnimations: Int, CaseIterable, PeripheralDataModel {
    
    //case tetris
    //case off        = 1
    case smooth     = 2
    case sharp      = 3
    
    var name: String {
        switch self {
        //case .off:          return "sl_pro_animations_off".localized
        case .smooth:       return "sl_pro_animations_stepByStep".localized
        case .sharp:        return "sl_pro_animations_sharp".localized
        }
    }
}
