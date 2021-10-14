//
//  SlBasePeripheral.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol SlBasePeripheralDelegate: DistanceSensorPeripheralDelegate { }

class SlBasePeripheral: BasePeripheral, DistanceSensorPeripheralProtocol {
    
    var delegate: SlBasePeripheralDelegate?
//    override var baseDelegate: BasePeripheralDelegate? {
//        get { return self.delegate }
//        set { self.delegate = newValue as! TorcherePeripheralDelegate?}
//    }
    private var model = SlBasePeripheralDataModel()

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service: BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.sensor,.topSensorTriggerDistance):
            // TODO: - Implement toInt() for double byte
            delegate?.getTopSensorTriggerDistance(distance: data.toInt())
            model.topSensorTriggerDistance = data.toInt()
            break
        case (.sensor,.botSensorTriggerDistance):
            // TODO: - Implement toInt() for double byte
            delegate?.getBotSensorTriggerDistance(distance: data.toInt())
            model.botSensorTriggerDistance = data.toInt()
            break
        default:
            break
        }
    }
    
}

