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
        print("torchere init")
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

enum TorchereAnimations: CaseIterable {
    case tetris
    case wave
    case transfusion
    case fullRainbow
    case rainbow
    case `static`
}

struct TorchereData {
    static let animationModes     : [Int:String] = [1: "Tetris",
                                                    2: "Wave",
                                                    3: "Transfusion",
                                                    4: "Full Rainbow",
                                                    5: "Rainbow",
                                                    6: "Static"]
    static let animationDirection : [Int:String] = [1: "From bottom",
                                                    2: "From top",
                                                    3: "To center",
                                                    4: "From center"]
}
