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
    var someDict: [[BluetoothEndpoint.Services:BluetoothEndpoint.Characteristics] : CBCharacteristic] { get set }
    var incomingData: [[BluetoothEndpoint.Services:BluetoothEndpoint.Characteristics] : Data] { get set }
    func readValue(_ value:Data, _ characteristic: BluetoothEndpoint.Characteristics)
}

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    func readValue(_ value: Data, _ characteristic: BluetoothEndpoint.Characteristics) {
        print("Base readValue")
    }
    
    let centralManager: CBCentralManager
    var peripheral: CBPeripheral
    var type : BasePeripheral.Type?
    var name: String
    var someDict: [[BluetoothEndpoint.Services : BluetoothEndpoint.Characteristics] : CBCharacteristic] = [:]
    var incomingData: [[BluetoothEndpoint.Services : BluetoothEndpoint.Characteristics] : Data] = [:]
    
    init(_ peripheral: CBPeripheral,_ manager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = manager
        self.name = peripheral.name ?? "Unknown Device".localized
        super.init()
        self.peripheral.delegate = self
    }
    
    func connect() {
        centralManager.delegate = self
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(name)")
    }
    
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(name)")
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(name)")
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(name) - \(String(describing: error?.localizedDescription))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
                print("Service found - \(service.uuid)")
            }
        }
    }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                if let cases = BluetoothEndpoint.getCases(service, characteristic) {
                    self.someDict[cases] = characteristic
                } else {
                    print("NO MATCH - \(characteristic.uuid) : \(service.uuid.uuidString)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("new value - \(characteristic.value)")
        if let value = characteristic.value,
           let char = BluetoothEndpoint.getCharacteristic(characteristic: characteristic) {
            readValue(value, char)
        }
        if let cases = BluetoothEndpoint.getCases(characteristic.service, characteristic) {
            self.incomingData[cases] = characteristic.value
        }
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

class FirstPeripheral: BasePeripheral, ColorPeripheral, AnimationPeripheral, DiplomPeripheral {

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        print("init")
        super.init(peripheral, manager)
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        print("writing")
        writePrimaryColor(color)
    }
    
    public func setAnimationMode(_ mode: Int) {
        print("GO - \n\(someDict.description)")
        peripheral.services?.forEach { c in
            c.characteristics?.forEach{ b in
                print("\(b.uuid) - \(b.service.uuid)")
            }
        }
    }
    
    public func setAnimationOnSpeed(_ speed: Int) {
        writeAnimationOnSpeed(speed)
    }
    
    func readPrimaryColor(_ color: UIColor) {
        print("HAHAHAHA Primary color is \(color)")
    }
    
    func readSecondaryColor(_ color: UIColor) {
        print("HAHAHAHA Secondary color \(color)")
    }
    
    func readRandomColor(_ color: Bool) {
        print("HAHAHAHA random is \(color)")
    }
}

class SecondPeripheral: BasePeripheral, ColorPeripheral {
        
    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        writePrimaryColor(color)
    }
    
    public func setSecondaryColor(_ color: UIColor) {
        writeSecondaryColor(color)
    }
    
    public func setRandomColor(_ isEnabled: Bool) {
        writeRandomColor(isEnabled)
    }
    
}

