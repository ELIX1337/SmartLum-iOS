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
    var endpoints: [[BluetoothEndpoint.Service:BluetoothEndpoint.Characteristic] : CBCharacteristic] { get set }
    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic?)
    func writeWithResponse(value: Data, to characteristic: CBCharacteristic?)
    func setFactorySettings()
}

extension BasePeripheralProtocol {
    var factorySettingsCharacteristic: CBCharacteristic? { get { self.endpoints[[.info:.factorySettings]] } }
    var demoModeCharacteristic:        CBCharacteristic? { get { self.endpoints[[.info:.demoMode]] } }
    
    func writeWithResponse(value: Data, to characteristic: CBCharacteristic?) {
        if let char = characteristic {
            self.peripheral.writeValue(value, for: char, type: .withResponse)
        }
    }
    
    func writeWithoutResponse(value: Data, to characteristic: CBCharacteristic?) {
        print("write \(value) - \(String(describing: characteristic?.uuid))")
        if let char = characteristic {
            if char.properties.contains(.writeWithoutResponse) {
                self.peripheral.writeValue(value, for: char, type: .withoutResponse)
                print("Writing (no response) to \(char.uuid.uuidString) - \(value)")
            } else {
                writeWithResponse(value: value, to: characteristic)
                print("Writing (response) to \(char.uuid.uuidString) - \(value)")
            }
        }
    }
    
    func setFactorySettings() {
        writeWithoutResponse(value: true.toData(), to: factorySettingsCharacteristic)
    }
    
    func enableDemoMode() {
        writeWithoutResponse(value: true.toData(), to: demoModeCharacteristic)
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
    func peripheralDemoMode(state: Bool)
}

extension BasePeripheralDelegate {
    func peripheralDemoMode(state: Bool) { }
}

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    let centralManager: CBCentralManager
    var peripheral: CBPeripheral
    var type: PeripheralProfile?
    var name: String
    var endpoints: [[BluetoothEndpoint.Service : BluetoothEndpoint.Characteristic] : CBCharacteristic] = [:]
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
    
    internal func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service:BluetoothEndpoint.Service, error: Error?) {
        switch (service, characteristic) {
        case (.info,.initState):
            baseDelegate?.peripheralInitState(isInitialized: data.toBool())
            break
        case (.event, .error):
            print("GOT ERROR - \(data.toInt())")
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
        case (.info, .demoMode):
            baseDelegate?.peripheralDemoMode(state: data.toBool())
            break
        default:
            break
        }
    }
    
    private func enableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Enabling notifications for \(characteristic.uuid)")
            peripheral.setNotifyValue(true, for: characteristic)
        } else {
            print("No NOTIFY property in \(characteristic.uuid)")
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
        guard let error = error else {
            if let services = peripheral.services {
                for service in services {
                    peripheral.discoverCharacteristics(nil, for: service)
                    print("Service found - \(service.uuid)")
                    lastService = services.last?.uuid
                }
            }
            return
        }
        print("Error while discovering \(name) services \(error.localizedDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let error = error else {
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
                //baseDelegate?.peripheralIsReady()
            }
            return
        }
        print("Error while discovering characteristics in \(service.uuid) - \(error.localizedDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descriptors = characteristic.descriptors {
            for descriptor in descriptors {
                peripheral.readValue(for: descriptor)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            return
        }
        print("Error while writing \(characteristic.uuid) - \(error.localizedDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            if let value = characteristic.value,
               let char = BluetoothEndpoint.getCharacteristic(characteristic: characteristic),
               let service = characteristic.service,
               let serv = BluetoothEndpoint.getService(service) {
                if !value.isEmpty {
                    readData(data: value, from: char, in: serv, error: error)
                }
            }
            if (lastService == characteristic.service?.uuid) {
                if (characteristic.service?.characteristics?.last == characteristic) {
                    baseDelegate?.peripheralIsReady()
                    print("LAST")
                }
            }
            return
        }
        print("Error reading \(characteristic.uuid) - \(error.localizedDescription)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            return
        }
        print("Error updating notification state for \(characteristic.uuid) - \(error.localizedDescription)")
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
