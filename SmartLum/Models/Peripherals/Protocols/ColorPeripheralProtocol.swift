//
//  ColorPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 30.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

/// Протокол периферийного устройства с возможностью управления цветом
protocol ColorPeripheralProtocol {
    func writePrimaryColor(_ color: UIColor)
    func writeSecondaryColor(_ color: UIColor)
    func writeRandomColor(_ state: Bool)
}

extension ColorPeripheralProtocol where Self:PeripheralProtocol {
    
    /// Основной цвет.
    /// Есть у любого устройства с цветом
    var primaryColorCharacteristic:   CBCharacteristic? { get { return self.endpoints[[.color:.primaryColor]] }  }
    
    /// Дополнительный цвет.
    /// Есть не у всех устройств
    var secondaryColorCharacteristic: CBCharacteristic? { get { return self.endpoints[[.color:.secondaryColor]] } }
    
    /// Случайный цвет.
    /// Есть не у всех устройств
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

// Вызывается при чтении данных с устройства
protocol ColorPeripheralDelegate {
    func getPrimaryColor(_ color: UIColor)
    func getSecondaryColor(_ color: UIColor)
    func getRandomColor(_ state: Bool)
}


