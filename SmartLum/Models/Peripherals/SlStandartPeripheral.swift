//
//  SlStandartPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

protocol SlStandartPeripheralDelegate: StairsPeripheralDelegate, DistanceSensorPeripheralDelegate, LightnessSensorPeripheralDelegate, LedPeripheralDelegate, AnimationPeripheralDelegate, ColorPeripheralDelegate { }

class SlStandartPeripheral: BasePeripheral, StairsPeripheralProtocol, DistanceSensorPeripheralProtocol, LightnessSensorPeripheralProtocol, LedPeripheralProtocol, AnimationPeripheralProtocol, ColorPeripheralProtocol {
    
    var delegate: SlBasePeripheralDelegate?
    
    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
        if !endpoints.keys.contains([.color: .primaryColor]) {
            
        }
    }
    
    override func readData(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service: BluetoothEndpoint.Service, error: Error?) {
        super.readData(data: data, from: characteristic, in: service, error: error)
        switch (service, characteristic) {
        case (.led, .ledBrightness):
            handleLedSettings(characteristic, data)
            break
        case (.stairs, .stepsCount):
            break
        case (.stairs, .standbyState),
            (.stairs, .standbyBrightness),
            (.stairs, .standbyTopCount),
            (.stairs, .standbyBotCount):
            handleStandbyModeSettings(characteristic, data)
            break
        case (.sensor, .topSensorTriggerDistance),
            (.sensor, .botSensorTriggerDistance),
            (.sensor, .topSensorCurrentDistance),
            (.sensor, .botSensorCurrentDistance):
            handleDistanceSettings(characteristic, data)
            break
        case (.sensor, .topSensorTriggerLightness),
            (.sensor, .botSensorTriggerLightness),
            (.sensor, .topSensorCurrentLightness),
            (.sensor, .botSensorCurrentLightness):
            handleLightnessSettings(characteristic, data)
            break
        case (.color, .primaryColor),
            (.color, .secondaryColor),
            (.color, .randomColor):
            handleColorSettings(characteristic, data)
            break
        case (.animation, .animationMode),
            (.animation, .animationDirection),
            (.animation, .animationStep),
            (.animation, .animationOnSpeed),
            (.animation, .animationOffSpeed):
            handleAnimationSettings(characteristic, data)
            break
        default:
            break
        }
    }
    
    func handleLedSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .ledBrightness:
            delegate?.getLedBrightness(brightness: value.toInt())
            break
        default:
            break
        }
    }
    
    func handleStandbyModeSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {

    }
    
    func handleDistanceSettings(_ settings: BluetoothEndpoint.Characteristic, _ value: Data) {
        
    }
    
    func handleLightnessSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        
    }
    
    func handleColorSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        
    }
    
    func handleAnimationSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        
    }
    
}
