//
//  TorcherePeripheral.swift
//  SmartLum
//
//  Created by Tim on 05.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

class TorcherePeripheral: BasePeripheral, ColorPeripheralProtocol, AnimationPeripheralProtocol {
    
    var delegate: (ColorPeripheralDelegate & AnimationPeripheralDelegate)?
    override var baseDelegate: BasePeripheralDelegate? {
        get { return self.delegate }
        set { self.delegate = newValue as! (ColorPeripheralDelegate & AnimationPeripheralDelegate)?}
    }
    
    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service: BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.color,.primaryColor):
            delegate?.getPrimaryColor(data.toUIColor())
            break
        case (.color,.secondaryColor):
            delegate?.getSecondaryColor(data.toUIColor())
            break
        case (.color,.randomColor):
            delegate?.getRandomColor(data.toBool())
            break
        case (.animation,.animationMode):
            delegate?.getAnimationMode(mode: Int(data.toUInt8()))
            break
        case (.animation,.animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: Int(data.toUInt8()))
            break
        case (.animation,.animationDirection):
            delegate?.getAnimationDirection(direction: Int(data.toUInt8()))
            break
        case (.animation,.animationStep):
            delegate?.getAnimationStep(step: Int(data.toUInt8()))
            break
        default:
            break
        }
    }
    
}

protocol PeripheralDataRow {
    var code: Int    { get }
    var name: String { get }
}

enum PeripheralAnimations: Int, CaseIterable, PeripheralDataRow {
    
    case tetris             = 1
    case wave               = 2
    case transfusion        = 3
    case rainbowTransfusion = 4
    case rainbow            = 5
    case `static`           = 6

    var name: String {
        switch self {
        case .tetris:               return "Tetris"
        case .wave:                 return "Wave"
        case .transfusion:          return "Transfusion"
        case .rainbowTransfusion:   return "Rainbow transfusion"
        case .rainbow:              return "Rainbow"
        case .static:               return "Static"
        }
    }
    var code: Int {{ return self.rawValue }()}
    
}

enum PeripheralAnimationDirections: Int, CaseIterable, PeripheralDataRow {
    
    case fromBottom = 1
    case fromTop    = 2
    case toCenter   = 3
    case fromCenter = 4
    
    var name: String {
        switch self {
        case .fromBottom: return "From bottom"
        case .fromTop:    return "From top"
        case .toCenter:   return "To center"
        case .fromCenter: return "From center"
        }
    }
    
    var code: Int {{ return self.rawValue }()}
    
}
