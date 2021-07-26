//
//  ColorPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol ColorPeripheralProtocol {
    func writePrimaryColor(_ color: UIColor)
    func writeSecondaryColor(_ color: UIColor)
    func writeRandomColor(_ state: Bool)
}

extension ColorPeripheralProtocol where Self:BasePeripheralProtocol {
    var randomColorCharacteristic   : CBCharacteristic? { get { return self.endpoints[[.color:.randomColor]] } }
    var primaryColorCharacteristic  : CBCharacteristic? { get { return self.endpoints[[.color:.primaryColor]] }  }
    var secondaryColorCharacteristic: CBCharacteristic? { get { return self.endpoints[[.color:.secondaryColor]] } }

    func writePrimaryColor(_ color: UIColor) {
        if let characteristic = primaryColorCharacteristic {
            peripheral.writeValue(color.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    
    func writeSecondaryColor(_ color: UIColor) {
        if let characteristic = secondaryColorCharacteristic {
            peripheral.writeValue(color.toData(), for: characteristic, type: .withoutResponse)
        }
    }
    
    func writeRandomColor(_ state: Bool) {
        if let characteristic = randomColorCharacteristic {
            peripheral.writeValue(state.toData(), for: characteristic, type: .withoutResponse)
        }
    }

}

protocol ColorPeripheralDelegate {
    func getPrimaryColor(_ color: UIColor)
    func getSecondaryColor(_ color: UIColor)
    func getRandomColor(_ state: Bool)
}


