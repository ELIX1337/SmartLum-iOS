//
//  SlProViewModel.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

// ViewModel устройства SL-Pro
class SlProViewModel: PeripheralViewModel {
    
    // Делаем downcast BasePeripheral в SlProPeripheral
    var slProPeripheral: SlProPeripheral! {
        get { return (super.basePeripheral as! SlProPeripheral) }
    }
    
    // Заранее декларируем ячейки для нашей tableView
    // Color section
    var primaryColorCell: CellModel!
    var randomColorCell: CellModel!
    // LED section
    var ledStateCell: CellModel!
    var ledBrightnessCell: CellModel!
    var ledTimeoutCell: CellModel!
    // Animation section
    var animationModeCell: CellModel!
    var animationSpeedCell: CellModel!
    // Sensor section
    var topTriggerDistanceCell: CellModel!
    var botTriggerDistanceCell: CellModel!
    var topTriggerLightnessCell: CellModel!
    var botTriggerLightnessCell: CellModel!
    var topCurrentDistanceCell: CellModel!
    var botCurrentDistanceCell: CellModel!
    var topCurrentLightnessCell: CellModel!
    var botCurrentLightnessCell: CellModel!

    // Stairs section
    var stairsWorkModeCell: CellModel!
    var controllerTypeCell: CellModel!
    var ledAdaptiveCell: CellModel!
    var stepsCountCell: CellModel!
    var topSensorCountCell: CellModel!
    var botSensorCountCell: CellModel!
    // Standby Lightness section
    var standbyStateCell: CellModel!
    var standbyBrightnessCell: CellModel!
    var standbyTopCountCell: CellModel!
    var standbyBotCountCell: CellModel!
    // Factory section
    var resetToFactoryCell: CellModel!
    
    // Публичные переменные для использования во ViewController'е
    // Используются чтобы инициализировать ColorPicker
    var primaryColor: UIColor {
        get {
            if let color = self.dataModel.getValue(key: StairsControllerData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral as! SlProPeripheral, delegate, selected)
        slProPeripheral.delegate = self
        self.tableView = withTableView
        self.onCellSelected = selected
        self.dataModel = StairsControllerData(values: [:])
        initColorSection()
        initLedSection()
        initAnimationSection()
        initSettingsSection()
        initReadyTableViewModel()
        initSettingsTableViewModel()
        initSetupTableViewModel()
    }
    
    // Аналогично остальным ViewModel
    private func initReadyTableViewModel() {
        readyTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell, randomColorCell]),
                SectionModel(
                    headerText: "peripheral_sl_pro_led_section_header".localized,
                    footerText: "peripheral_sl_pro_led_section_footer".localized,
                    rows: [ledStateCell, ledBrightnessCell, ledTimeoutCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell])
            ], type: .ready)
    }
    
    // Аналогично остальным ViewModel
    private func initSettingsTableViewModel() {
        settingsTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_sl_pro_steps_settings_section_header".localized,
                    footerText: "peripheral_sl_pro_steps_settings_section_footer".localized,
                    rows: [controllerTypeCell, ledAdaptiveCell, stairsWorkModeCell, stepsCountCell, topSensorCountCell, botSensorCountCell]),
                SectionModel(
                    key: "StandbySection",
                    headerText: "peripheral_sl_pro_standby_section_header".localized,
                    footerText: "peripheral_sl_pro_standby_section_footer".localized,
                    rows: [standbyStateCell, standbyBrightnessCell, standbyTopCountCell, standbyBotCountCell]),
                SectionModel(
                    headerText: "peripheral_sl_pro_sensor_trigger_distance_section_header".localized,
                    footerText: "peripheral_sl_pro_sensor_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_sl_pro_sensor_trigger_lightness_section_header".localized,
                    footerText: "peripheral_sl_pro_sensor_trigger_lightness_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell]),
                SectionModel(
                    headerText: "peripheral_sl_pro_sensor_current_lightness_section_header".localized,
                    footerText: "peripheral_sl_pro_sensor_current_lightness_section_footer".localized,
                    rows: [topCurrentLightnessCell, botCurrentLightnessCell]),
                SectionModel(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell]),
            ], type: .settings)
    }
    
    // Аналогично остальным ViewModel
    private func initSetupTableViewModel() {
        setupTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell])
            ], type: .setup)
    }
    
    // Аналогично остальным ViewModel
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: StairsControllerData.primaryColorKey,
            title: "peripheral_sl_pro_color_cell_title".localized,
            initialValue: UIColor.white, callback: { _ in })
        randomColorCell = .switchCell(
            key: StairsControllerData.randomColorKey,
            title: "peripheral_sl_pro_random_color_cell_title".localized,
            initialValue: false,
            callback: { self.writeRandomColor(state: $0) })
    }

    // Аналогично остальным ViewModel
    private func initLedSection() {
        ledStateCell = .switchCell(
            key: StairsControllerData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: false,
            callback: { self.writeLedState(state: $0) })
        ledBrightnessCell = .sliderCell(
            key: StairsControllerData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(StairsControllerData.slProLedMinBrightness),
            minValue: Float(StairsControllerData.slProLedMinBrightness),
            maxValue: Float(StairsControllerData.slProLedMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        ledTimeoutCell = .stepperCell(
            key: StairsControllerData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(StairsControllerData.slProLedMinTimeout),
            maxValue: Double(StairsControllerData.slProLedMaxTimeout),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
    }
    
    // Аналогично остальным ViewModel
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: StairsControllerData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: "")
        animationSpeedCell = .sliderCell(
            key: StairsControllerData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(StairsControllerData.slProAnimationMinSpeed),
            minValue: Float(StairsControllerData.slProAnimationMinSpeed),
            maxValue: Float(StairsControllerData.slProAnimationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
    }
    
    // Аналогично остальным ViewModel
    private func initSettingsSection() {
        topTriggerDistanceCell = .sliderCell(
            key: StairsControllerData.topTriggerDistanceKey,
            title: "peripheral_sl_pro_top_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(StairsControllerData.slProSensorMinDistance),
            minValue: Float(StairsControllerData.slProSensorMinDistance),
            maxValue: Float(StairsControllerData.slProSensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerDistance(value: Int($0)) })
        botTriggerDistanceCell = .sliderCell(
            key: StairsControllerData.botTriggerDistanceKey,
            title: "peripheral_sl_pro_bot_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(StairsControllerData.slProSensorMinDistance),
            minValue: Float(StairsControllerData.slProSensorMinDistance),
            maxValue: Float(StairsControllerData.slProSensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerDistance(value: Int($0)) })
        topTriggerLightnessCell = .sliderCell(
            key: StairsControllerData.topTriggerLightnessKey,
            title: "peripheral_sl_pro_top_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerLightness(value: Int($0)) })
        botTriggerLightnessCell = .sliderCell(
            key: StairsControllerData.botTriggerLightnessKey,
            title: "peripheral_sl_pro_bot_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerLightness(value: Int($0)) })
        topCurrentDistanceCell = .infoCell(
            key: StairsControllerData.topCurrentDistanceKey,
            titleText: "peripheral_sl_pro_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        botCurrentDistanceCell = .infoCell(
            key: StairsControllerData.botCurrentDistanceKey,
            titleText: "peripheral_sl_pro_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        stairsWorkModeCell = .pickerCell(
            key: StairsControllerData.stairsWorkModeKey,
            title: "peripheral_sl_pro_stairs_work_mode_cell_title".localized,
            initialValue: PeripheralStairsWorkMode.bySensors.name)
        controllerTypeCell = .infoCell(
            key: StairsControllerData.controllerTypeKey,
            titleText: "peripheral_sl_pro_controller_type_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: UITableViewCell.AccessoryType.none)
        ledAdaptiveCell = .pickerCell(
            key: StairsControllerData.ledAdaptiveModeKey,
            title: "peripheral_sl_pro_adaptive_brightness_cell_title".localized,
            initialValue: PeripheralLedAdaptiveMode.off.name)
        stepsCountCell = .stepperCell(
            key: StairsControllerData.stepsCountKey,
            title: "peripheral_sl_pro_steps_count_cell".localized,
            initialValue: Double(StairsControllerData.slProSensorMinCount),
            minValue: Double(StairsControllerData.slProStepsMinCount),
            maxValue: Double(StairsControllerData.slProStepsMaxCount),
            callback: { self.writeStepsCount(count: Int($0)) })
        topSensorCountCell = .stepperCell(
            key: StairsControllerData.topSensorCountKey,
            title: "peripheral_sl_pro_top_sensor_count_cell_title".localized,
            initialValue: Double(StairsControllerData.slProSensorMinCount),
            minValue: Double(StairsControllerData.slProSensorMinCount),
            maxValue: Double(StairsControllerData.slProSensorMaxCount),
            callback: { self.writeTopSensorCount(count: Int($0)) })
        botSensorCountCell = .stepperCell(
            key: StairsControllerData.topSensorCountKey,
            title: "peripheral_sl_pro_bot_sensor_count_cell_title".localized,
            initialValue: 0,
            minValue: Double(StairsControllerData.slProSensorMinCount),
            maxValue: Double(StairsControllerData.slProSensorMaxCount),
            callback: { self.writeBotSensorCount(count: Int($0)) })
        standbyStateCell = .switchCell(
            key: StairsControllerData.standbyStateKey,
            title: "peripheral_sl_pro_standby_state".localized,
            initialValue: false,
            callback: { self.writeStandbyState(state: $0) })
        standbyBrightnessCell = .sliderCell(
            key: StairsControllerData.standbyBrightnessKey,
            title: "peripheral_sl_pro_standby_brightness".localized,
            initialValue: 0,
            minValue: Float(StairsControllerData.slProLedMinBrightness),
            maxValue: Float(StairsControllerData.slProLedMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeStandbyBrightness(value: Int($0)) })
        standbyTopCountCell = .stepperCell(
            key: StairsControllerData.standbyTopCountKey,
            title: "peripheral_sl_pro_standby_top_count".localized,
            initialValue: 0,
            minValue: Double(StairsControllerData.slProStandbyMinCount),
            maxValue: Double(StairsControllerData.slProStandbyMaxCount),
            callback: { self.writeStandbyTopCount(count: Int($0)) })
        standbyBotCountCell = .stepperCell(
            key: StairsControllerData.standbyBotCountKey,
            title: "peripheral_sl_pro_standby_bot_count".localized,
            initialValue: 0,
            minValue: Double(StairsControllerData.slProStandbyMinCount),
            maxValue: Double(StairsControllerData.slProStandbyMaxCount),
            callback: { self.writeStandbyBotCount(count: Int($0)) })
        resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
        topCurrentLightnessCell = .infoCell(
            key: StairsControllerData.topCurrentLightnessKey,
            titleText: "peripheral_sl_pro_top_current_lightness_cell_title".localized,
            detailText: nil,
            image: nil,
            accessory: nil)
        botCurrentLightnessCell = .infoCell(
            key: StairsControllerData.botCurrentLightnessKey,
            titleText: "peripheral_sl_pro_bot_current_lightness_cell_title".localized,
            detailText: nil,
            image: nil,
            accessory: nil)
    }
    
    /// Скрываем или показываем ячейки в зависмости от адаптивной яркости.
    /// Аналогично обработки режима анимации во FlClassicViewModel - топорно, прямолинейно, но быстро.
    private func handleAdaptiveMode(mode: PeripheralLedAdaptiveMode) {
        switch mode {
        case .off:
            showCells(cells: [ledBrightnessCell], inModel: readyTableViewModel!)
            showCells(cells: [standbyBrightnessCell], inModel: settingsTableViewModel!)
            break
        default:
            hideCells(cells: [ledBrightnessCell], inModel: readyTableViewModel!)
            hideCells(cells: [standbyBrightnessCell], inModel: settingsTableViewModel!)
            break
        }
    }
    
    /// Так же обрабатываем UI в зависимости от типа ленты.
    /// Если лента цветная, то показываем ячейки для управлением цветом, если нет, то скрываем.
    private func handleLedType(type: SlProControllerType) {
        switch type {
        case .`default`:
            hideCells(cells: [primaryColorCell, randomColorCell], inModel: readyTableViewModel!)
            break
        case .rgb:
            showCells(cells: [primaryColorCell, randomColorCell], inModel: readyTableViewModel!)
            break
        }
    }
    
    // Публичные методы
    func writePrimaryColor(_ color: UIColor) {
        if (dataModel.getValue(key: StairsControllerData.primaryColorKey) as? UIColor != color) {
            slProPeripheral.writePrimaryColor(color)
            dataModel.setValue(key: StairsControllerData.primaryColorKey, value: color)
            updateCell(for: primaryColorCell, with: .none)
        }
    }
    
    func writeRandomColor(state: Bool) {
        dataModel.setValue(key: StairsControllerData.randomColorKey, value: state)
        slProPeripheral.writeRandomColor(state)
    }
    
    func writeAnimationMode(mode: SlProAnimations) {
        guard mode.name != dataModel.getValue(key: StairsControllerData.animationModeKey) as! String else { return }
        dataModel.setValue(key: StairsControllerData.animationModeKey, value: mode.name)
        slProPeripheral.writeAnimationMode(mode)
        updateCell(for: animationModeCell, with: .none)
    }
    
    func writeLedType(type: SlProControllerType) {
        dataModel.setValue(key: StairsControllerData.controllerTypeKey, value: type)
        slProPeripheral.writeLedType(type)
        updateCell(for: controllerTypeCell, with: .none)
        handleLedType(type: type)
    }
    
    func writeLedState(state: Bool) {
        dataModel.setValue(key: StairsControllerData.ledStateKey, value: state)
        slProPeripheral.writeLedState(state)
    }
    
    func writeLedBrightness(value: Int) {
        if (dataModel.getValue(key: StairsControllerData.ledBrightnessKey) as? Int != value) {
            dataModel.setValue(key: StairsControllerData.ledBrightnessKey, value: value)
            slProPeripheral.writeLedBrightness(value)
        }
    }
    
    func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: StairsControllerData.ledTimeoutKey, value: timeout)
        slProPeripheral.writeLedTimeout(Int(timeout))
    }
    
    func writeLedAdaptiveBrightnessMode(mode: PeripheralLedAdaptiveMode) {
        dataModel.setValue(key: StairsControllerData.ledAdaptiveModeKey, value: mode.name)
        slProPeripheral.writeLedAdaptiveBrightnessState(mode)
        updateCell(for: ledAdaptiveCell, with: .none)
        // Обновляем UI
        handleAdaptiveMode(mode: mode)
    }
    
    func writeAnimationSpeed(speed: Int) {
        if (dataModel.getValue(key: StairsControllerData.animationSpeedKey) as? Int != speed) {
            dataModel.setValue(key: StairsControllerData.animationSpeedKey, value: speed)
            slProPeripheral.writeAnimationOnSpeed(speed)
        }
    }
    
    func writeTopTriggerDistance(value: Int) {
        if (dataModel.getValue(key: StairsControllerData.topTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: StairsControllerData.topTriggerDistanceKey, value: value)
            slProPeripheral.writeTopSensorTriggerDistance(value)
        }
    }
    
    func writeBotTriggerDistance(value: Int) {
        if (dataModel.getValue(key: StairsControllerData.botTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: StairsControllerData.botTriggerDistanceKey, value: value)
            slProPeripheral.writeBotSensorTriggerDistance(value)
        }
    }
    
    func writeTopTriggerLightness(value: Int) {
        dataModel.setValue(key: StairsControllerData.topTriggerLightnessKey, value: value)
        slProPeripheral.writeTopSensorLightness(value)
    }
    
    func writeBotTriggerLightness(value: Int) {
        dataModel.setValue(key: StairsControllerData.botTriggerLightnessKey, value: value)
        slProPeripheral.writeBotSensorLightness(value)
    }
    
    func writeStairsWorkMode(mode: PeripheralStairsWorkMode) {
        dataModel.setValue(key: StairsControllerData.stairsWorkModeKey, value: mode.name)
        slProPeripheral.writeStairsWorkMode(mode)
        updateCell(for: stairsWorkModeCell, with: .none)
    }
    
    func writeStepsCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.stepsCountKey, value: count)
        slProPeripheral.writeStepsCount(count)
    }
    
    func writeTopSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.topSensorCountKey, value: count)
        slProPeripheral.writeTopSensorCount(count)
    }
    
    func writeBotSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.botSensorCountKey, value: count)
        slProPeripheral.writeBotSensorCount(count)
    }
    
    func writeStandbyState(state: Bool) {
        dataModel.setValue(key: StairsControllerData.standbyStateKey, value: state)
        slProPeripheral.writeStandbyState(state)
    }
    
    func writeStandbyBrightness(value: Int) {
        if (dataModel.getValue(key: StairsControllerData.standbyBrightnessKey) as? Int != value) {
            dataModel.setValue(key: StairsControllerData.standbyBrightnessKey, value: value)
            slProPeripheral.writeStandbyBrightness(value)
        }
    }
    
    func writeStandbyTopCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.standbyTopCountKey, value: count)
        slProPeripheral.writeStandbyTopCount(count)
    }
    
    func writeStandbyBotCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.standbyBotCountKey, value: count)
        slProPeripheral.writeStandbyBotCount(count)
    }
    
    private func initTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: StairsControllerData.topTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as! Int != 0
    }
    
    private func initBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: StairsControllerData.botTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as! Int != 0
    }
    
    private func initStepsCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.stepsCountKey, value: count)
    }
    
    private func initTopSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.topSensorCountKey, value: count)
    }
    
    private func initBotSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.botSensorCountKey, value: count)
    }
    
}

/// Методы делегата SlProPeripheral (прием данных)
extension SlProViewModel: SlProPeripheralDelegate {
    
    func getWorkMode(mode: PeripheralDataModel) {
        dataModel.setValue(key: StairsControllerData.stairsWorkModeKey, value: mode.name)
        updateCell(for: stairsWorkModeCell, with: .middle)
    }
    
    func getTopSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.topSensorCountKey, value: count)
        updateCell(for: topSensorCountCell, with: .middle)
    }
    
    func getBotSensorCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.botSensorCountKey, value: count)
        updateCell(for: botSensorCountCell, with: .middle)
    }
    
    func getLedType(type: PeripheralDataModel) {
        dataModel.setValue(key: StairsControllerData.controllerTypeKey, value: type.name)
        updateCell(for: controllerTypeCell, with: .middle)
        handleLedType(type: type as! SlProControllerType)
    }
    
    func getLedAdaptiveBrightnessState(mode: PeripheralDataModel) {
        dataModel.setValue(key: StairsControllerData.ledAdaptiveModeKey, value: mode.name)
        updateCell(for: ledAdaptiveCell, with: .middle)
        handleAdaptiveMode(mode: mode as! PeripheralLedAdaptiveMode)
    }
    
    func getStepsCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.stepsCountKey, value: count)
        updateCell(for: stepsCountCell, with: .middle)
    }
    
    func getStandbyState(state: Bool) {
        dataModel.setValue(key: StairsControllerData.standbyStateKey, value: state)
        updateCell(for: standbyStateCell, with: .middle)
    }
    
    func getStandbyBrightness(brightness: Int) {
        dataModel.setValue(key: StairsControllerData.standbyBrightnessKey, value: brightness)
        updateCell(for: standbyBrightnessCell, with: .middle)
    }
    
    func getStandbyTopCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.standbyTopCountKey, value: count)
        updateCell(for: standbyTopCountCell, with: .middle)
    }
    
    func getStandbyBotCount(count: Int) {
        dataModel.setValue(key: StairsControllerData.standbyBotCountKey, value: count)
        updateCell(for: standbyBotCountCell, with: .middle)
    }
    
    func getTopSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: StairsControllerData.topTriggerLightnessKey, value: lightness)
        updateCell(for: topTriggerLightnessCell, with: .middle)
        print("TOP TRIGGER LIGHTNESS- \(lightness) - \(dataModel.getValue(key: StairsControllerData.topTriggerLightnessKey))")
    }
    
    func getBotSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: StairsControllerData.botTriggerLightnessKey, value: lightness)
        updateCell(for: botTriggerLightnessCell, with: .middle)
        print("BOT TRIGGER LIGHTNESS- \(lightness) - \(dataModel.getValue(key: StairsControllerData.botTriggerLightnessKey))")
    }
    
    func getTopSensorCurrentLightness(lightness: Int) {
        dataModel.setValue(key: StairsControllerData.topCurrentLightnessKey, value: lightness)
        updateCell(for: topCurrentLightnessCell, with: .none)
    }
    
    func getBotSensorCurrentLightness(lightness: Int) {
        dataModel.setValue(key: StairsControllerData.botCurrentLightnessKey, value: lightness)
        updateCell(for: botCurrentLightnessCell, with: .none)
    }
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: StairsControllerData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: StairsControllerData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: StairsControllerData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
        print("TOP TRIGGER DISTANCE- \(distance) - \(dataModel.getValue(key: StairsControllerData.topTriggerDistanceKey))")
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: StairsControllerData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
        print("BOT TRIGGER DISTANCE- \(distance) - \(dataModel.getValue(key: StairsControllerData.botTriggerDistanceKey))")
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: StairsControllerData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: StairsControllerData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: StairsControllerData.ledTimeoutKey, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getAnimationMode(mode: PeripheralDataModel) {
        dataModel.setValue(key: StairsControllerData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .middle)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: StairsControllerData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    // Не используется
    func getSecondaryColor(_ color: UIColor) { }
    func getAnimationOffSpeed(speed: Int) { }
    func getAnimationStep(step: Int) { }
    func getAnimationDirection(direction: PeripheralDataModel) { }
    
}
