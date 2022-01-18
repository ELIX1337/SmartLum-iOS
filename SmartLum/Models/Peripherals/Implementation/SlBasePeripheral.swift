//
//  SlBasePeripheral.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

/// Делегат (ViewModel), который получит приведенные в нормальный вид данные с устройства
protocol SlBasePeripheralDelegate: DistanceSensorPeripheralDelegate, LedPeripheralDelegate, AnimationPeripheralDelegate { }

/// Конкретная реализация устройства SL-Base (контроллер освещения лестницы).
/// Реализует управление датчиками дистанции, лентой, анимациями
class SlBasePeripheral: BasePeripheral, DistanceSensorPeripheralProtocol, LedPeripheralProtocol, AnimationPeripheralProtocol {
    
    var delegate: SlBasePeripheralDelegate?

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    /// Прием данных с устройства.
    /// Вызываем super метод, чтобы он обработал чтение стандартных данных для всех устройств.
    /// Делаем override чтобы обработать прием уже конкретных данных
    override func dataReceived(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service: BluetoothEndpoint.Service, error: Error?) {
        super.dataReceived(data: data, from: characteristic, in: service, error: error)
        switch (service, characteristic) {
        case (.sensor,.topSensorTriggerDistance):
            delegate?.getTopSensorTriggerDistance(distance: data.toInt())
            break
        case (.sensor,.botSensorTriggerDistance):
            delegate?.getBotSensorTriggerDistance(distance: data.toInt())
            break
        case (.led, .ledState):
            delegate?.getLedState(state: data.toBool())
            break
        case (.led, .ledBrightness):
            delegate?.getLedBrightness(brightness: data.toInt())
            break
        case (.led, .ledTimeout):
            delegate?.getLedTimeout(timeout: data.toInt())
            break
        case (.animation, .animationOnSpeed):
            delegate?.getAnimationOnSpeed(speed: data.toInt())
            break
        default:
            break
        }
    }
    
}

