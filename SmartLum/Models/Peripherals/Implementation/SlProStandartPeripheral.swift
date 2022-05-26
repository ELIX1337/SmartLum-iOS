//
//  SlProPeripheral.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

/// Делегат (ViewModel), который получит приведенные в нормальный вид данные с устройства
protocol SlProPeripheralDelegate: StairsPeripheralDelegate, DistanceSensorPeripheralDelegate, LightnessSensorPeripheralDelegate, LedPeripheralDelegate, AnimationPeripheralDelegate, ColorPeripheralDelegate { }

/// Конкретная реализация устройства SL-Pro (контроллер освещения лестницы).
/// Реализует управление ступенями, датчиками дистанции, датчиками освещенности, лентой, анимациями, цветами
class SlProStandartPeripheral: BasePeripheral, StairsPeripheralProtocol, DistanceSensorPeripheralProtocol, LightnessSensorPeripheralProtocol, LedPeripheralProtocol, AnimationPeripheralProtocol, ColorPeripheralProtocol {
    
    var delegate: SlProPeripheralDelegate?
    
    override init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        super.init(peripheral, manager)
    }
    
    /// Прием данных с устройства.
    /// Вызываем super метод, чтобы он обработал чтение стандартных данных для всех устройств.
    /// Делаем override чтобы обработать прием уже конкретных данных
    override func dataReceived(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service: BluetoothEndpoint.Service, error: Error?) {
        super.dataReceived(data: data, from: characteristic, in: service, error: error)
        print("RECEIVED - \(characteristic) - \(data)")
        switch (service, characteristic) {
        case (.led, .ledBrightness),
            (.led, .ledState),
            (.led, .ledTimeout),
            (.led, .ledType),
            (.led, .ledAdaptiveBrightness):
            handleLedSettings(characteristic, data)
            break
        case (.stairs, .stepsCount),
            (.stairs, .workMode),
            (.stairs, .topSensorCount),
            (.stairs, .botSensorCount):
            handleStairsSettings(characteristic, data)
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
    
    /// Обрабатывает данные связанные со ступенями
    func handleStairsSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .stepsCount:
            delegate?.getStepsCount(count: value.toInt())
            break
        case .workMode:
            delegate?.getWorkMode(mode: PeripheralStairsWorkMode(rawValue: value.toInt()) ?? .bySensors)
            break
        case .topSensorCount:
            delegate?.getTopSensorCount(count: value.toInt())
            break
        case .botSensorCount:
            delegate?.getBotSensorCount(count: value.toInt())
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные со светодиодной лентой
    func handleLedSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .ledState:
            delegate?.getLedState(state: value.toBool())
            break
        case .ledBrightness:
            delegate?.getLedBrightness(brightness: value.toInt())
            break
        case .ledTimeout:
            delegate?.getLedTimeout(timeout: value.toInt())
            delegate?.getLedType(type: SlProStandartControllerType.default)
            break
        case .ledType:
            delegate?.getLedType(type: SlProStandartControllerType(rawValue: value.toInt()) ?? .default)
            break
        case .ledAdaptiveBrightness:
            delegate?.getLedAdaptiveBrightnessState(mode: PeripheralLedAdaptiveMode(rawValue: value.toInt()) ?? .off)
            break
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные с дежурной подсветкой
    func handleStandbyModeSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .standbyState:
            delegate?.getStandbyState(state: value.toBool())
            break
        case .standbyBrightness:
            delegate?.getStandbyBrightness(brightness: value.toInt())
            break
        case .standbyTopCount:
            delegate?.getStandbyTopCount(count: value.toInt())
            break
        case .standbyBotCount:
            delegate?.getStandbyBotCount(count: value.toInt())
            break
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные с датчиками дистанции (движения)
    func handleDistanceSettings(_ settings: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch settings {
        case .topSensorTriggerDistance:
            delegate?.getTopSensorTriggerDistance(distance: value.toInt())
            break
        case .botSensorTriggerDistance:
            delegate?.getBotSensorTriggerDistance(distance: value.toInt())
            break
        case .topSensorCurrentDistance:
            delegate?.getTopSensorCurrentDistance(distance: value.toInt())
            break
        case .botSensorCurrentDistance:
            delegate?.getBotSensorCurrentDistance(distance: value.toInt())
            break
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные с датчиками освещенности
    func handleLightnessSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .topSensorTriggerLightness:
            delegate?.getTopSensorTriggerLightness(lightness: value.toInt())
            break
        case .botSensorTriggerLightness:
            delegate?.getBotSensorTriggerLightness(lightness: value.toInt())
            break
        case .topSensorCurrentLightness:
            delegate?.getTopSensorCurrentLightness(lightness: value.toInt())
            break
        case .botSensorCurrentLightness:
            delegate?.getBotSensorCurrentLightness(lightness: value.toInt())
            break
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные с цветом ленты
    func handleColorSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .primaryColor:
            delegate?.getPrimaryColor(value.toUIColor())
            break
        case .randomColor:
            delegate?.getRandomColor(value.toBool())
            break
        default:
            break
        }
    }
    
    /// Обрабатывает данные связанные с анимациями
    func handleAnimationSettings(_ setting: BluetoothEndpoint.Characteristic, _ value: Data) {
        switch setting {
        case .animationMode:
            delegate?.getAnimationMode(mode: SlProStandartAnimations(rawValue: value.toInt()) ?? .sharp)
            break
        case .animationOnSpeed:
            delegate?.getAnimationOnSpeed(speed: value.toInt())
            break
        default:
            break
        }
    }
    
}
