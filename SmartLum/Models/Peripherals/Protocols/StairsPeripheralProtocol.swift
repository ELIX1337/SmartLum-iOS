//
//  StairsPeripheralProtocol.swift
//  SmartLum
//
//  Created by ELIX on 08.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth

// Протокол периферийного устройства со ступенями
protocol StairsPeripheralProtocol {
    func writeStepsCount(_ count: Int)
    func writeStandbyState(_ state: Bool)
    func writeStandbyBrightness(_ brightness: Int)
    func writeStandbyTopCount(_ count: Int)
    func writeStandbyBotCount(_ count: Int)
    func writeStairsWorkMode(_ mode: PeripheralDataElement)
    func writeTopSensorCount(_ count: Int)
    func writeBotSensorCount(_ count: Int)
}

extension StairsPeripheralProtocol where Self:PeripheralProtocol {
    
    /// Количество ступеней
    var stepsCountCharacteristic:        CBCharacteristic? { get { self.endpoints[[.stairs:.stepsCount]] } }
    
    /// Состояние дежурной подсветки (вкл или выкл)
    var standbyStateCharacteristic:      CBCharacteristic? { get { self.endpoints[[.stairs:.standbyState]] } }
    
    /// Яркость дежурной подсветки
    var standbyBrightnessCharacteristic: CBCharacteristic? { get { self.endpoints[[.stairs:.standbyBrightness]] } }
    
    /// Количество ступеней дежурной подсветки СВЕРХУ
    var standbyTopCountCharacteristic:   CBCharacteristic? { get { self.endpoints[[.stairs:.standbyTopCount]] } }
    
    /// Количество ступеней дежурной подсветки СНИЗУ
    var standbyBotCountCharacteristic:   CBCharacteristic? { get { self.endpoints[[.stairs:.standbyBotCount]] } }
    
    /// Режим работы (по датчикам или по времени)
    var stairsWorkModeChracteristic:     CBCharacteristic? { get { self.endpoints[[.stairs:.workMode]] } }
    
    /// Количество верхних датчиков
    var topSensorCountCharacteristic:    CBCharacteristic? { get { self.endpoints[[.stairs:.topSensorCount]] } }
    
    /// Количество нижних датчиков
    var botSensorCountCharacteristic:    CBCharacteristic? { get { self.endpoints[[.stairs:.botSensorCount]] } }
    
    func writeStepsCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: stepsCountCharacteristic)
    }
    func writeStandbyState(_ state: Bool) {
        writeWithoutResponse(value: state.toData(), to: standbyStateCharacteristic)
    }
    
    func writeStandbyBrightness(_ brightness: Int) {
        writeWithoutResponse(value: brightness.toDynamicSizeData(), to: standbyBrightnessCharacteristic)
    }
    
    func writeStandbyTopCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: standbyTopCountCharacteristic)
    }
    
    func writeStandbyBotCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: standbyBotCountCharacteristic)
    }
    
    func writeStairsWorkMode(_ mode: PeripheralDataElement) {
        writeWithoutResponse(value: mode.code.toDynamicSizeData(), to: stairsWorkModeChracteristic)
    }
    
    func writeTopSensorCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: topSensorCountCharacteristic)
    }

    func writeBotSensorCount(_ count: Int) {
        writeWithoutResponse(value: count.toDynamicSizeData(), to: botSensorCountCharacteristic)
    }
    
}

// Вызывается при чтении данных с устройства
protocol StairsPeripheralDelegate {
    func getStepsCount(count: Int)
    func getStandbyState(state: Bool)
    func getStandbyBrightness(brightness: Int)
    func getStandbyTopCount(count: Int)
    func getStandbyBotCount(count: Int)
    func getWorkMode(mode: PeripheralDataElement)
    func getTopSensorCount(count: Int)
    func getBotSensorCount(count: Int)
}
