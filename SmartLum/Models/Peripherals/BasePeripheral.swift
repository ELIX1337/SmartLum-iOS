//
//  SLPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 04.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

protocol BasePeripheralProtocol {
    var peripheral: CBPeripheral { get set }
    var endpoints: [[BluetoothEndpoint.Services:BluetoothEndpoint.Characteristics] : CBCharacteristic] { get set }
    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic)
    func setFactorySettings()
}

extension BasePeripheralProtocol {
    var factorySettingsCharacteristic: CBCharacteristic? { get { self.endpoints[[.info:.factorySettings]] } }

    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic) {
        if peripheral.canSendWriteWithoutResponse {
            self.peripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    
    func setFactorySettings() {
        if let characteristic = factorySettingsCharacteristic {
            writeWithoutResponse(value: true.toData(), to: characteristic)
        }
    }
    
}

protocol BasePeripheralDelegate {
    func peripheralDidConnect()
    func peripheralDidDisconnect(reason: Error?)
    func peripheralIsReady()
    func peripheralInitState(isInitialized: Bool)
    func peripheralError(code: Int)
    func peripheralFirmwareVersion(_ version: Int)
    func peripheralOnDFUMode()
}

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    let centralManager: CBCentralManager
    var peripheral: CBPeripheral
    var type : PeripheralProfile?
    var name: String
    var endpoints: [[BluetoothEndpoint.Services : BluetoothEndpoint.Characteristics] : CBCharacteristic] = [:]
    public var isConnected: Bool { peripheral.state == .connected }
    var baseDelegate: BasePeripheralDelegate?
    var lastService: CBUUID?
    
    init(_ peripheral: CBPeripheral,_ manager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = manager
        self.name = peripheral.name ?? "peripheral_name_unknown".localized
        super.init()
        self.peripheral.delegate = self
    }
    
    func connect() {
        centralManager.delegate = self
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(name)")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            if (!self.isConnected) {
                self.centralManager.cancelPeripheralConnection(self.peripheral)
            }
        }
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(name)")
    }
    
    internal func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service:BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.info,.initState):
            baseDelegate?.peripheralInitState(isInitialized: data.toBool())
            break
        case (.event, .error):
            print("ERROR CODE - \(data.toInt())")
            baseDelegate?.peripheralError(code: data.toInt())
            break
        case (.info, .dfu):
            if (data.toBool()) {
                baseDelegate?.peripheralOnDFUMode()
            }
            break
        case (.info, .firmwareVersion):
            baseDelegate?.peripheralFirmwareVersion(data.toInt())
            break
        default:
            break
        }
    }
    
    private func enableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Enabling notifications for \(characteristic.uuid) characteristic...")
            peripheral.setNotifyValue(true, for: characteristic)
        } else {
            print("Can't enable notifications for characterestic \(characteristic.uuid), characteristic doesn't contain NOTIFY property")
        }
    }
    
    public func readInitCharacteristic() {
        if let characteristic = endpoints[[.info:.initState]] {
            peripheral.readValue(for:characteristic)
        }
    }
    
    // MARK: - CBCentralManagerDelegate & CBPeripheralDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(name)")
        baseDelegate?.peripheralDidConnect()
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(name) - \(String(describing: error?.localizedDescription))")
        baseDelegate?.peripheralDidDisconnect(reason: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                print("Service found - \(service.uuid)")
                lastService = services.last?.uuid
            }
        }
    }
            
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                enableNotifications(for: characteristic)
                peripheral.readValue(for: characteristic)
                //peripheral.discoverDescriptors(for: characteristic)
                if let cases = BluetoothEndpoint.getCases(service, characteristic) {
                    self.endpoints[cases] = characteristic
                } else {
                    print("Unknown characteristic- \(characteristic.uuid) : \(service.uuid.uuidString)")
                }
            }
        }
        if service.uuid == lastService {
            baseDelegate?.peripheralIsReady()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descriptors = characteristic.descriptors {
            for descriptor in descriptors {
                peripheral.readValue(for: descriptor)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value,
           let char = BluetoothEndpoint.getCharacteristic(characteristic: characteristic),
           let service = characteristic.service,
           let serv = BluetoothEndpoint.getService(service) {
            readData(data: value, from: char, in: serv, error: error)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
    }
    
    // MARK: - NSObject
    override func isEqual(_ object: Any?) -> Bool {
        if object is BasePeripheral {
            let peripheralObject = object as! BasePeripheral
            return peripheralObject.peripheral.identifier == peripheral.identifier
        } else if object is CBPeripheral {
            let peripheralObject = object as! CBPeripheral
            return peripheralObject.identifier == peripheral.identifier
        } else {
            return false
        }
    }
    
}
