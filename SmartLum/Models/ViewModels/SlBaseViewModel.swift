//
//  SlBaseViewModel.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

// ViewModel устройства SL-Base
class SlBaseViewModel: PeripheralViewModel {
    
    // Делаем downcast BasePeripheral в SlBasePeripheral
    var slBasePeripheral: SlBasePeripheral! {
        get { return (super.basePeripheral as! SlBasePeripheral) }
    }
    
    // Заранее декларируем ячейки для нашей tableView
    var topTriggerDistanceCell: CellModel!
    var botTriggerDistanceCell: CellModel!
    var ledStateCell:           CellModel!
    var ledBrightnessCell:      CellModel!
    var ledTimeoutCell:         CellModel!
    var animationSpeedCell:     CellModel!
    var resetToFactoryCell:     CellModel!
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        slBasePeripheral.delegate = self
        dataModel = PeripheralData(peripheralType: .SlBase)
        initCells()
        initReadyTableViewModel()
        initSetupTableViewModel()
        initSettingsTableViewModel()
    }
    
    /// Иницализируем все ячейки
    private func initCells() {
        self.topTriggerDistanceCell = .sliderCell(
            key: PeripheralData.topTriggerDistanceKey,
            title: "peripheral_top_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(dataModel.sensorDistance.min),
            maxValue: Float(dataModel.sensorDistance.max),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopSensorTriggerDistance(distance: Int($0)) })
        self.botTriggerDistanceCell = .sliderCell(
            key: PeripheralData.botTriggerDistanceKey,
            title: "peripheral_bot_sensor_cell_title".localized,
            initialValue: 1,
            minValue: Float(dataModel.sensorDistance.min),
            maxValue: Float(dataModel.sensorDistance.max),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotSensorTriggerDistance(distance: Int($0)) })
        self.ledStateCell = .switchCell(
            key: PeripheralData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: false,
            callback: { self.writeLedState(state: $0) })
        self.ledBrightnessCell = .sliderCell(
            key: PeripheralData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(dataModel.ledBrightness.min),
            minValue: Float(dataModel.ledBrightness.min),
            maxValue: Float(dataModel.ledBrightness.max),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        self.ledTimeoutCell = .stepperCell(
            key: PeripheralData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: Double(dataModel.ledTimeout.min),
            minValue: Double(dataModel.ledTimeout.min),
            maxValue: Double(dataModel.ledTimeout.max),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
        self.animationSpeedCell = .sliderCell(
            key: PeripheralData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(dataModel.animationSpeed.min),
            minValue: Float(dataModel.animationSpeed.min),
            maxValue: Float(dataModel.animationSpeed.max),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
        self.resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
    }
    
    /// Инициализируем tableViewModel для  главного экрана
    private func initReadyTableViewModel() {
        readyTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_led_state_section_header".localized,
                    footerText: "peripheral_led_state_section_footer".localized,
                    rows: [ledStateCell]),
                SectionModel(
                    headerText: "peripheral_led_brightness_section_header".localized,
                    footerText: "peripheral_led_brightness_section_footer".localized,
                    rows: [ledBrightnessCell]),
                SectionModel(
                    headerText: "peripheral_additional_section_header".localized,
                    footerText: "peripheral_additional_section_footer".localized,
                    rows: [animationSpeedCell,
                           ledTimeoutCell])
            ], type: .ready)
    }
    
    /// Инициализируем tableViewModel для экрана настройки устройства (инициализации)
    private func initSetupTableViewModel() {
        setupTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_setup_trigger_distance_section_header".localized,
                    footerText: "peripheral_setup_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell])
            ], type: .setup)
    }
    
    /// Инициализируем tableViewModel для экрана расширенных настроек
    private func initSettingsTableViewModel() {
        settingsTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_sensor_trigger_distance_section_header".localized,
                    footerText: "peripheral_sensor_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell])
            ], type: .settings)
    }
    
    /// Публичный метод для включения/выключения ленты
    public func writeLedState(state: Bool) {
        dataModel.setValue(key: PeripheralData.ledStateKey, value: state)
        slBasePeripheral.writeLedState(state)
        updateCell(for: ledStateCell, with: .none)
    }
    
    /// Публичный метод для управления яркостью ленты
    public func writeLedBrightness(value: Int) {
        dataModel.setValue(key: PeripheralData.ledBrightnessKey, value: value)
        slBasePeripheral.writeLedBrightness(value)
        updateCell(for: ledBrightnessCell, with: .none)
    }
    
    /// Публичный метод для задания таймаута ленты
    public func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: PeripheralData.ledTimeoutKey, value: timeout)
        slBasePeripheral.writeLedTimeout(timeout)
        updateCell(for: ledTimeoutCell, with: .none)
    }
    
    /// Публичный метод для управления скоростью включения ленты
    public func writeAnimationSpeed(speed: Int) {
        dataModel.setValue(key: PeripheralData.animationSpeedKey, value: speed)
        slBasePeripheral.writeAnimationOnSpeed(speed)
        updateCell(for: animationSpeedCell, with: .none)
    }
    
    /// Этот метод используется при первичной настройке (инициализации) устройства.
    /// Запись данных произойдет только в том случае, когда в dataModel будут лежать необходимые данные.
    /// Для этого пользователь должен "подвигать" оба слайдера.
//    public func writeInitDistance() -> Bool {
//        if let top = dataModel.getValue(key: PeripheralData.topTriggerDistanceKey),
//           let bot = dataModel.getValue(key: PeripheralData.botTriggerDistanceKey) {
//            slBasePeripheral.writeTopSensorTriggerDistance(top as! Int)
//            slBasePeripheral.writeBotSensorTriggerDistance(bot as! Int)
//            return true
//        }
//        return false
//    }
    
    /// Этот метод для записи дистанции срабатывания используется из 2 мест.
    /// 1. При первичной настройке устройства (инициализации).
    /// 2. Из экрана расширенных настроек.
    public func writeTopSensorTriggerDistance(distance: Int) {
        // Кидаем данные в dataModel
        dataModel.setValue(key: PeripheralData.topTriggerDistanceKey, value: distance)
        // Проверяем, инициализировано ли устройство
        if isInitialized {
            // Инициализировано, отправляем данные на устройство (экран расширенных настроек)
            slBasePeripheral.writeTopSensorTriggerDistance(distance)
        } else {
            // Не инициализировано - не пишем, отправка данных произойдет по кнопке "подтвердить".
            // Поэтому проверяем, готовы ли мы к отправке данных (смотреть метод requiresInit ниже)
            isInitWriteAvailable()
        }
    }
    
    /// Так же логика, что и у предыдущего метода
    public func writeBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: PeripheralData.botTriggerDistanceKey, value: distance)
        if isInitialized {
            slBasePeripheral.writeBotSensorTriggerDistance(distance)
        } else {
            isInitWriteAvailable()
        }
    }
    
    /// Переопределяем функцию.
    /// В теле указываем условие, при котором становится возможным запись данных при инициализации.
    /// В данном случае запись возможна, когда пользователь указал дистанции для верхнего и нижнего датчиков.
    /// По сути тут мы просто указываем все настройки, которые есть на экране инициализации устройства.
    override func isInitDataAvailable() -> Bool {
        let first  = dataModel.getValue(key: PeripheralData.botTriggerDistanceKey) as? Int != 0
        let second = dataModel.getValue(key: PeripheralData.topTriggerDistanceKey) as? Int != 0
        // Если обе переменные не пустые (в них записали данные)
        return first && second
    }
    
    override func writeInitData() -> Bool {
        if let top = dataModel.getValue(key: PeripheralData.topTriggerDistanceKey),
           let bot = dataModel.getValue(key: PeripheralData.botTriggerDistanceKey) {
            slBasePeripheral.writeTopSensorTriggerDistance(top as! Int)
            slBasePeripheral.writeBotSensorTriggerDistance(bot as! Int)
            return true
        }
        return false
    }
    
}

/// Методы делегата устройства SL-Base (прием данных).
extension SlBaseViewModel: SlBasePeripheralDelegate {
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: PeripheralData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: PeripheralData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: PeripheralData.ledTimeoutKey, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: PeripheralData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: PeripheralData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
        print("TOP TRIGGER - \(distance)")
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: PeripheralData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
        print("BOT TRIGGER - \(distance)")
    }
    
    // Не используется
    func getAnimationMode(mode: PeripheralDataModel) { }
    
    func getAnimationOffSpeed(speed: Int) { }
    
    func getAnimationDirection(direction: PeripheralDataModel) { }
    
    func getAnimationStep(step: Int) { }
    
    func getTopSensorCurrentDistance(distance: Int) { }
    
    func getBotSensorCurrentDistance(distance: Int) { }

    
}


