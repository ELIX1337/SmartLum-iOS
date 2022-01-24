//
//  PeripheralError.swift
//  SmartLum
//
//  Created by ELIX on 18.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import Foundation

/// Типы ошибок
enum PeripheralError: Int, CaseIterable, PeripheralDataModel {
    
    case error1 = 0x01
    case error2 = 0x02
    case error3 = 0x03
    
    var name: String {
        switch self {
        case .error1: return "Error 1"
        case .error2: return "Error 2"
        case .error3: return "Error 3"
        }
    }
        
    var description: String {
        switch self {
        case .error1: return "peripheral_error_code_1_description".localized
        case .error2: return "peripheral_error_code_2_description".localized
        case .error3: return "peripheral_error_code_2_description".localized
        }
    }

}
