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
    //var baseDelegate: BasePeripheralDelegate? { get set }
}

protocol BasePeripheralDelegate {
    func peripheralDidConnect()
    func peripheralDidDisconnect()
    func peripheralIsReady()
    func peripheralFirmwareVersion(_ version: Int)
    func peripheralOnDFUMode()
}

class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      BasePeripheralProtocol {
    
    let centralManager: CBCentralManager
    var peripheral: CBPeripheral
    var type : BasePeripheral.Type?
    var name: String
    var endpoints: [[BluetoothEndpoint.Services : BluetoothEndpoint.Characteristics] : CBCharacteristic] = [:]
    public var isConnected: Bool { peripheral.state == .connected }
    var baseDelegate: BasePeripheralDelegate?
    
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
        baseDelegate?.peripheralDidConnect()
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
    
    func readData(data: Data,from characteristic: BluetoothEndpoint.Characteristics, in service:BluetoothEndpoint.Services, error: Error?) {
        
    }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
                if let cases = BluetoothEndpoint.getCases(service, characteristic) {
                    self.endpoints[cases] = characteristic
                } else {
                    print("NO MATCH - \(characteristic.uuid) : \(service.uuid.uuidString)")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value,
           let char = BluetoothEndpoint.getCharacteristic(characteristic: characteristic),
           let serv = BluetoothEndpoint.getService(characteristic.service) {
            readData(data: value, from: char, in: serv, error: error)
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

class FirstPeripheral: BasePeripheral, ColorPeripheralProtocol, AnimationPeripheralProtocol, DiplomPeripheral {
    
    public var delegate: (ColorPeripheralDelegate & AnimationPeripheralDelegate)?

    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        print("init")
        super.init(peripheral, manager)
    }
    
    public func setPrimaryColor(_ color: UIColor) {
        print("writing")
        writePrimaryColor(color)
    }
    
    public func setAnimationMode(_ mode: Int) {
        if let char = endpoints[[.animation:.animationMode]] {
            peripheral.readValue(for: char)
        }
    }
    
    public func setAnimationOnSpeed(_ speed: Int) {
        writeAnimationOnSpeed(speed)
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristics, in service: BluetoothEndpoint.Services, error: Error?) {
        switch (service, characteristic) {
        case (.animation,.animationMode):
            delegate?.getAnimationMode(mode: Int(data.toUInt8()))
            print("Animation service - animation mode: \(data.toUInt8())")
            break
        case (.color,.primaryColor):
            delegate?.getPrimaryColor(data.toUIColor())
            break
        default:
            print("Unknown data")
        }
    }
}

class SecondPeripheral: BasePeripheral, ColorPeripheralProtocol {
        
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

