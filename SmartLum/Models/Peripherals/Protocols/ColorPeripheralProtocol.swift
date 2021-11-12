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
    var primaryColorCharacteristic:   CBCharacteristic? { get { return self.endpoints[[.color:.primaryColor]] }  }
    var secondaryColorCharacteristic: CBCharacteristic? { get { return self.endpoints[[.color:.secondaryColor]] } }
    var randomColorCharacteristic:    CBCharacteristic? { get { return self.endpoints[[.color:.randomColor]] } }

    func writePrimaryColor(_ color: UIColor) {
        writeWithoutResponse(value: color.toData(), to: primaryColorCharacteristic)
    }
    
    func writeSecondaryColor(_ color: UIColor) {
        writeWithoutResponse(value: color.toData(), to: secondaryColorCharacteristic)
    }
    
    func writeRandomColor(_ state: Bool) {
        writeWithoutResponse(value: state.toData(), to: randomColorCharacteristic)
    }

}

protocol ColorPeripheralDelegate {
    func getPrimaryColor(_ color: UIColor)
    func getSecondaryColor(_ color: UIColor)
    func getRandomColor(_ state: Bool)
}


