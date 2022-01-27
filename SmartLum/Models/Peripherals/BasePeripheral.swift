//
//  BasePeripheral.swift
//  SmartLum
//
//  Created by ELIX on 04.06.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import CoreBluetooth
import UIKit

// Базовый класс периферийного устройства
/// Отвечает за коннект, дисконнект, чтение, запись
/// От него наследуются конкретные устройства
class BasePeripheral: NSObject,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      PeripheralProtocol {
    
    let centralManager: CBCentralManager
    
    var peripheral: CBPeripheral
    
    /// Тип устройства. Инициализируется в сканнере.
    var deviceType: PeripheralProfile!
    
    var name: String
    
    var endpoints: [[BluetoothEndpoint.Service : BluetoothEndpoint.Characteristic] : CBCharacteristic] = [:]
    
    public var isConnected: Bool { peripheral.state == .connected }
    
    var baseDelegate: BasePeripheralDelegate?
    
    var lastService: CBUUID?
    
    init(_ peripheral: CBPeripheral, _ manager: CBCentralManager) {
        self.peripheral = peripheral
        self.centralManager = manager
        self.name = peripheral.name ?? "peripheral_name_unknown".localized
        super.init()
        self.peripheral.delegate = self
    }
    
    // Соединение с устройством
    /// Есть таймаут, после которого произойдет отключение от устройства в случае если никак не удается подключиться
    func connect() {
        centralManager.delegate = self
        centralManager.connect(peripheral, options: nil)
        print("Connecting to \(name)")
        
        // Таймаут
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 15) {
            if (!self.isConnected) {
                self.centralManager.cancelPeripheralConnection(self.peripheral)
            }
        }
    }
    
    // Отключение от устройства
    func disconnect() {
        centralManager.cancelPeripheralConnection(peripheral)
        print("Disconnecting from \(name)")
    }
    
    // Метод, который считывает значение с характеристики
    /// Можно увидеть, что он тут он считывает стандартные данные с устройства
    /// Нужно делать override этого метода в конкретных подклассах (не забудь вызвать super) чтобы считать необходимые для конкретного устройства данные
    /// Комментарий: Да, switch-case мне тоже не нравится, но это быстро и дешево
    internal func dataReceived(data: Data, from characteristic: BluetoothEndpoint.Characteristic, in service:BluetoothEndpoint.Service, error: Error?) {
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
    
    // Включает уведомления (notifications) для характеристики
    /// Если включить, то при изменении данных в характеристике будет автоматически происходить их считывание
    /// Примечание: для этого в настройках  характеристики должен быть настроен соотвествующий атрибут
    private func enableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Enabling notifications for \(characteristic.uuid)")
            peripheral.setNotifyValue(true, for: characteristic)
        } else {
            print("No NOTIFY property in \(characteristic.uuid)")
        }
    }
    
    // Выключает уведомления (notifications) для характеристики
    private func disableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.properties.contains(.notify) {
            print("Disabling notifications for \(characteristic.uuid)")
            peripheral.setNotifyValue(false, for: characteristic)
        } else {
            print("No NOTIFY property in \(characteristic.uuid)")
        }
    }
    
    /// Включает notify для всех поддерживаемых характеристик
    public func enableAllNotifications() {
        peripheral.services?.forEach { service in
            service.characteristics?.forEach { characteristic in
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    print("ALL NOTIFY: Enabled notifications for \(characteristic.uuid)")
                }
            }
        }
    }
    
    /// Публичная функция чтобы включать notify извне
    public func enableNotifications(forCharacterictic: BluetoothEndpoint.Characteristic, inService: BluetoothEndpoint.Service) {
        if let char = endpoints[[inService:forCharacterictic]] {
            enableNotifications(for: char)
        } else {
            print("Can't find characteristic for notifying")
        }
    }
    
    /// Публичная функция чтобы выключать notify извне
    public func disableNotifications(forCharacterictic: BluetoothEndpoint.Characteristic, inService: BluetoothEndpoint.Service) {
        if let char = endpoints[[inService:forCharacterictic]] {
            disableNotifications(for: char)
        } else {
            print("Can't find characteristic for disabling notify")
        }
    }
    
    // Считывает значение с характеристики, которая показывает состояние инициализации устройства
    public func readInitCharacteristic() {
        if let characteristic = endpoints[[.info:.initState]] {
            peripheral.readValue(for:characteristic)
        }
    }
    
    // MARK: - CBCentralManagerDelegate & CBPeripheralDelegate
    /// Методы делегата Bluetooth адаптера смартфона
    
    // Вызывается когда Bluetooth адаптер изменил свое состояние (вкл, выкл и тд.)
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central Manager state changed to \(central.state)")
        }
    }
    
    // Вызывается когда произошло соединение с периферийным устройством
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to \(name)")
        
        // Отправляем это дальше по цепочке
        baseDelegate?.peripheralDidConnect()
        
        // Начинаем считывать ВЕСЬ Bluetooth стэк периферийного устройства
        /// Ответ придет в метод didDiscoverServices
        peripheral.discoverServices(nil)
    }
    
    // Вызывается когда произошло отключение от устройства
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Disconnected from \(name) - \(String(describing: error?.localizedDescription))")
        baseDelegate?.peripheralDidDisconnect(reason: error)
    }
    
    // Вызывается когда на периферийном устройстве нашли нужные нам сервисы (в данном случае все)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Проверяем наличие ошибок
        guard let error = error else {
            if let services = peripheral.services {
                for service in services {
                    // Начинаем по очереди искать характеристики в сервисах
                    /// Ответ придет в метод didDiscoverCharacteristicsFor
                    peripheral.discoverCharacteristics(nil, for: service)
                    
                    // Запоминаем, какой сервис последний в очереди
                    // Нужно для того, чтобы потом отследить окончание чтения и вызвать метод peripheralIsReady()
                    lastService = services.last?.uuid
                    print("Service found - \(service.uuid)")
                }
            }
            return
        }
        print("Error while discovering \(name) services \(error.localizedDescription)")
    }
    
    // Вызывается когда нашли нужные нам характеристики в сервисе (в данном случае все)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Проверяем наличие ошибок
        guard let error = error else {
            if let characteristics = service.characteristics {
                for characteristic in characteristics {
                    
                    // Включаем уведомления в характеристике
                    // Перенес вызов этой функции 

                    // enableNotifications(for: characteristic)
                    
                    // Считываем значение с характеристики
                    peripheral.readValue(for: characteristic)
                    
                    // Считываем дескрипторы в характреистике (не понадобилось, но это должно быть тут)
                    //peripheral.discoverDescriptors(for: characteristic)
                    
                    // Здесь мы сохраняем найденную характеристику в массив ключ-значение
                    /// Зачем? Чтобы отправить данные на устройство, нужно записывать в конкретную характеристику
                    /// Тут то мы их и запоминаем, а затем найдем нужную нам характеристику по необходимому ключу и запишем в нее данные
                    /// Типы характеристик заранее определены в enum'e BluetoothEndpoint, мы просто находим соответствующий case в нем и делаем из него ключ
                    if let cases = BluetoothEndpoint.getCases(service, characteristic) {
                        self.endpoints[cases] = characteristic
                    } else {
                        print("Unknown characteristic- \(characteristic.uuid) : \(service.uuid.uuidString)")
                    }
                }
            }
            return
        }
        print("Error while discovering characteristics in \(service.uuid) - \(error.localizedDescription)")
    }
    
    // Вызывается когда нашли дескрипторы в характеристике (не используется)
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let descriptors = characteristic.descriptors {
            for descriptor in descriptors {
                peripheral.readValue(for: descriptor)
            }
        }
    }
    
    // Чтение данных с дескриптора (не используется)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) { }
    
    // Вызывается после записи данных в характеристику ЧЕРЕЗ МЕТОД writeWithResponse
    /// Сюда собственно и приходит этот response об удачной или неудачной записи
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            return
        }
        print("Error while writing \(characteristic.uuid) - \(error.localizedDescription)")
    }
    
    // Чтение данных с характеристики (читай с периферийного устройства)
    /// Вызывается когда был вызван метод readValue для характеристики
    /// Вызывается когда на характеристике включен notify и в ней изменилось значение (само периферийное устройство что-то записало в нее)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Проверяем наличие ошибок
        guard let error = error else {
            /// Проверяем наличие данных в характеристике
            /// Получаем по характеристике ее case из BluetoothEndpoint
            /// Отправляем данные дальше, обозначив с какой характеристики они пришли
            if let value = characteristic.value,
               let char = BluetoothEndpoint.getCharacteristic(characteristic: characteristic),
               let service = characteristic.service,
               let serv = BluetoothEndpoint.getService(service) {
                if !value.isEmpty {
                    dataReceived(data: value, from: char, in: serv, error: error)
                }
            }
            
            // Проверяем, был ли это последний сервис
            /// Если да, то чтение данных закончено и устройство готово к работе
            /// Нужно только для первичного чтения данных с устройства (после подключения)
            if (lastService == characteristic.service?.uuid) {
                if (characteristic.service?.characteristics?.last == characteristic) {
                    baseDelegate?.peripheralIsReady()
                    lastService = nil
                }
            }
            return
        }
        print("Error reading \(characteristic.uuid) - \(error.localizedDescription)")
    }
    
    // Вызывается когда на характеристике включился notify или возникла ошибка при попытке его включить
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        guard let error = error else {
            return
        }
        print("Error updating notification state for \(characteristic.uuid) - \(error.localizedDescription)")
    }
    
    // MARK: - NSObject
    // Делаем возможным проведение операции сравнения для класса
    
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
