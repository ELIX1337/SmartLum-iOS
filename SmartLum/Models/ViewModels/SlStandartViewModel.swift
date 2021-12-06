//
//  SlStandartViewModel.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlStandartViewModel: PeripheralViewModel {
    
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
    
    var primaryColor: UIColor {
        get {
            if let color = self.dataModel.getValue(key: SlStandartData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    var slStandartPeripheral: SlStandartPeripheral! {
        get { return (super.basePeripheral as! SlStandartPeripheral) }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral as! SlStandartPeripheral, delegate, selected)
        slStandartPeripheral.delegate = self
        self.tableView = withTableView
        self.onCellSelected = selected
        self.dataModel = SlStandartData(values: [:])
        initColorSection()
        initLedSection()
        initAnimationSection()
        initSettingsSection()
        initReadyTableViewModel()
        initSettingsTableViewModel()
        initSetupTableViewModel()
    }
    
    private func initReadyTableViewModel() {
        readyTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell, randomColorCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_led_section_header".localized,
                    footerText: "peripheral_sl_standart_led_section_footer".localized,
                    rows: [ledStateCell, ledBrightnessCell, ledTimeoutCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell])
            ], type: .ready)
    }
    
    private func initSettingsTableViewModel() {
        settingsTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_sl_standart_steps_settings_section_header".localized,
                    footerText: "peripheral_sl_standart_steps_settings_section_footer".localized,
                    rows: [controllerTypeCell, ledAdaptiveCell, stairsWorkModeCell, stepsCountCell, topSensorCountCell, botSensorCountCell]),
                SectionModel(
                    key: "StandbySection",
                    headerText: "peripheral_sl_standart_standby_section_header".localized,
                    footerText: "peripheral_sl_standart_standby_section_footer".localized,
                    rows: [standbyStateCell, standbyBrightnessCell, standbyTopCountCell, standbyBotCountCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_sensor_trigger_distance_section_header".localized,
                    footerText: "peripheral_sl_standart_sensor_trigger_distance_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerDistanceCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_sensor_trigger_lightness_section_header".localized,
                    footerText: "peripheral_sl_standart_sensor_trigger_lightness_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell]),
                SectionModel(
                    headerText: "peripheral_sl_standart_sensor_current_lightness_section_header".localized,
                    footerText: "peripheral_sl_standart_sensor_current_lightness_section_footer".localized,
                    rows: [topCurrentLightnessCell, botCurrentLightnessCell]),
                SectionModel(
                    headerText: "peripheral_factory_settings_section_header".localized,
                    footerText: "peripheral_factory_settings_section_footer".localized,
                    rows: [resetToFactoryCell]),
            ], type: .settings)
    }
    
    private func initSetupTableViewModel() {
        setupTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [topTriggerDistanceCell, botTriggerLightnessCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [topTriggerLightnessCell, botTriggerLightnessCell])
            ], type: .setup)
    }
    
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: SlStandartData.primaryColorKey,
            title: "peripheral_sl_standart_color_cell_title".localized,
            initialValue: UIColor.white, callback: { _ in })
        randomColorCell = .switchCell(
            key: SlStandartData.randomColorKey,
            title: "peripheral_sl_standart_random_color_cell_title".localized,
            initialValue: false,
            callback: { self.writeRandomColor(state: $0) })
    }
    
    private func initLedSection() {
        ledStateCell = .switchCell(
            key: SlStandartData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: false,
            callback: { self.writeLedState(state: $0) })
        ledBrightnessCell = .sliderCell(
            key: SlStandartData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(SlStandartData.ledMinBrightness),
            minValue: Float(SlStandartData.ledMinBrightness),
            maxValue: Float(SlStandartData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        ledTimeoutCell = .stepperCell(
            key: SlStandartData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.ledMinTimeout),
            maxValue: Double(SlStandartData.ledMaxTimeout),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
    }
    
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: SlStandartData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: "")
        animationSpeedCell = .sliderCell(
            key: SlStandartData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(SlStandartData.animationMinSpeed),
            minValue: Float(SlStandartData.animationMinSpeed),
            maxValue: Float(SlStandartData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
    }
    
    private func initSettingsSection() {
        topTriggerDistanceCell = .sliderCell(
            key: SlStandartData.topTriggerDistanceKey,
            title: "peripheral_sl_standart_top_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlStandartData.sensorMinDistance),
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerDistance(value: Int($0)) })
        botTriggerDistanceCell = .sliderCell(
            key: SlStandartData.botTriggerDistanceKey,
            title: "peripheral_sl_standart_bot_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlStandartData.sensorMinDistance),
            minValue: Float(SlStandartData.sensorMinDistance),
            maxValue: Float(SlStandartData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerDistance(value: Int($0)) })
        topTriggerLightnessCell = .sliderCell(
            key: SlStandartData.topTriggerLightnessKey,
            title: "peripheral_sl_standart_top_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerLightness(value: Int($0)) })
        botTriggerLightnessCell = .sliderCell(
            key: SlStandartData.botTriggerLightnessKey,
            title: "peripheral_sl_standart_bot_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerLightness(value: Int($0)) })
        topCurrentDistanceCell = .infoCell(
            key: SlStandartData.topCurrentDistanceKey,
            titleText: "peripheral_sl_standart_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        botCurrentDistanceCell = .infoCell(
            key: SlStandartData.topCurrentDistanceKey,
            titleText: "peripheral_sl_standart_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        stairsWorkModeCell = .pickerCell(
            key: SlStandartData.stairsWorkModeKey,
            title: "peripheral_sl_standart_stairs_work_mode_cell_title".localized,
            initialValue: PeripheralStairsWorkMode.bySensors.name)
        controllerTypeCell = .infoCell(
            key: SlStandartData.controllerTypeKey,
            titleText: "peripheral_sl_standart_controller_type_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: UITableViewCell.AccessoryType.none)
        ledAdaptiveCell = .pickerCell(
            key: SlStandartData.ledAdaptiveModeKey,
            title: "peripheral_sl_standart_adaptive_brightness_cell_title".localized,
            initialValue: PeripheralLedAdaptiveMode.off.name)
        stepsCountCell = .stepperCell(
            key: SlStandartData.stepsCountKey,
            title: "peripheral_sl_standart_steps_count_cell".localized,
            initialValue: Double(SlStandartData.sensorMinCount),
            minValue: Double(SlStandartData.stepsMinCount),
            maxValue: Double(SlStandartData.stepsMaxCount),
            callback: { self.writeStepsCount(count: Int($0)) })
        topSensorCountCell = .stepperCell(
            key: SlStandartData.topSensorCountKey,
            title: "peripheral_sl_standart_top_sensor_count_cell_title".localized,
            initialValue: Double(SlStandartData.sensorMinCount),
            minValue: Double(SlStandartData.sensorMinCount),
            maxValue: Double(SlStandartData.sensorMaxCount),
            callback: { self.writeTopSensorCount(count: Int($0)) })
        botSensorCountCell = .stepperCell(
            key: SlStandartData.topSensorCountKey,
            title: "peripheral_sl_standart_bot_sensor_count_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.sensorMinCount),
            maxValue: Double(SlStandartData.sensorMaxCount),
            callback: { self.writeBotSensorCount(count: Int($0)) })
        standbyStateCell = .switchCell(
            key: SlStandartData.standbyStateKey,
            title: "peripheral_sl_standart_standby_state".localized,
            initialValue: false,
            callback: { self.writeStandbyState(state: $0) })
        standbyBrightnessCell = .sliderCell(
            key: SlStandartData.standbyBrightnessKey,
            title: "peripheral_sl_standart_standby_brightness".localized,
            initialValue: 0,
            minValue: Float(SlStandartData.ledMinBrightness),
            maxValue: Float(SlStandartData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeStandbyBrightness(value: Int($0)) })
        standbyTopCountCell = .stepperCell(
            key: SlStandartData.standbyTopCountKey,
            title: "peripheral_sl_standart_standby_top_count".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.standbyMinCount),
            maxValue: Double(SlStandartData.standbyMaxCount),
            callback: { self.writeStandbyTopCount(count: Int($0)) })
        standbyBotCountCell = .stepperCell(
            key: SlStandartData.standbyBotCountKey,
            title: "peripheral_sl_standart_standby_bot_count".localized,
            initialValue: 0,
            minValue: Double(SlStandartData.standbyMinCount),
            maxValue: Double(SlStandartData.standbyMaxCount),
            callback: { self.writeStandbyBotCount(count: Int($0)) })
        resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
        topCurrentLightnessCell = .infoCell(
            key: SlStandartData.topCurrentLightnessKey,
            titleText: "peripheral_sl_standart_top_current_lightness_cell_title".localized,
            detailText: nil,
            image: nil,
            accessory: nil)
        botCurrentLightnessCell = .infoCell(
            key: SlStandartData.botCurrentLightnessKey,
            titleText: "peripheral_sl_standart_bot_current_lightness_cell_title".localized,
            detailText: nil,
            image: nil,
            accessory: nil)
    }
    
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
    
    private func handleLedType(type: SlStandartControllerType) {
        switch type {
        case .`default`:
            hideCells(cells: [primaryColorCell, randomColorCell], inModel: readyTableViewModel!)
            break
        case .rgb:
            showCells(cells: [primaryColorCell, randomColorCell], inModel: readyTableViewModel!)
            break
        }
    }
    
    func writePrimaryColor(_ color: UIColor) {
        if (dataModel.getValue(key: SlStandartData.primaryColorKey) as? UIColor != color) {
            slStandartPeripheral.writePrimaryColor(color)
            dataModel.setValue(key: SlStandartData.primaryColorKey, value: color)
            updateCell(for: primaryColorCell, with: .none)
        }
    }
    
    func writeRandomColor(state: Bool) {
        dataModel.setValue(key: SlStandartData.randomColorKey, value: state)
        slStandartPeripheral.writeRandomColor(state)
    }
    
    func writeAnimationMode(mode: SlStandartAnimations) {
        guard mode.name != dataModel.getValue(key: SlStandartData.animationModeKey) as! String else { return }
        dataModel.setValue(key: SlStandartData.animationModeKey, value: mode.name)
        slStandartPeripheral.writeAnimationMode(mode)
        updateCell(for: animationModeCell, with: .none)
    }
    
    func writeLedType(type: SlStandartControllerType) {
        dataModel.setValue(key: SlStandartData.controllerTypeKey, value: type)
        slStandartPeripheral.writeLedType(type)
        updateCell(for: controllerTypeCell, with: .none)
        handleLedType(type: type)
    }
    
    func writeLedState(state: Bool) {
        dataModel.setValue(key: SlStandartData.ledStateKey, value: state)
        slStandartPeripheral.writeLedState(state)
    }
    
    func writeLedBrightness(value: Int) {
        if (dataModel.getValue(key: SlStandartData.ledBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.ledBrightnessKey, value: value)
            slStandartPeripheral.writeLedBrightness(value)
        }
    }
    
    func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlStandartData.ledTimeoutKey, value: timeout)
        slStandartPeripheral.writeLedTimeout(Int(timeout))
    }
    
    func writeLedAdaptiveBrightnessMode(mode: PeripheralLedAdaptiveMode) {
        dataModel.setValue(key: SlStandartData.ledAdaptiveModeKey, value: mode.name)
        slStandartPeripheral.writeLedAdaptiveBrightnessState(mode)
        updateCell(for: ledAdaptiveCell, with: .none)
        handleAdaptiveMode(mode: mode)
    }
    
    func writeAnimationSpeed(speed: Int) {
        if (dataModel.getValue(key: SlStandartData.animationSpeedKey) as? Int != speed) {
            dataModel.setValue(key: SlStandartData.animationSpeedKey, value: speed)
            slStandartPeripheral.writeAnimationOnSpeed(speed)
        }
    }
    
    func writeTopTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: value)
            slStandartPeripheral.writeTopSensorTriggerDistance(value)
        }
    }
    
    func writeBotTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: value)
            slStandartPeripheral.writeBotSensorTriggerDistance(value)
        }
    }
    
    func writeTopTriggerLightness(value: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerLightnessKey, value: value)
        slStandartPeripheral.writeTopSensorLightness(value)
    }
    
    func writeBotTriggerLightness(value: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerLightnessKey, value: value)
        slStandartPeripheral.writeBotSensorLightness(value)
    }
    
    func writeStairsWorkMode(mode: PeripheralStairsWorkMode) {
        dataModel.setValue(key: SlStandartData.stairsWorkModeKey, value: mode.name)
        slStandartPeripheral.writeStairsWorkMode(mode)
        updateCell(for: stairsWorkModeCell, with: .none)
    }
    
    func writeStepsCount(count: Int) {
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
        slStandartPeripheral.writeStepsCount(count)
    }
    
    func writeTopSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.topSensorCountKey, value: count)
        slStandartPeripheral.writeTopSensorCount(count)
    }
    
    func writeBotSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.botSensorCountKey, value: count)
        slStandartPeripheral.writeBotSensorCount(count)
    }
    
    func writeStandbyState(state: Bool) {
        dataModel.setValue(key: SlStandartData.standbyStateKey, value: state)
        slStandartPeripheral.writeStandbyState(state)
    }
    
    func writeStandbyBrightness(value: Int) {
        if (dataModel.getValue(key: SlStandartData.standbyBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlStandartData.standbyBrightnessKey, value: value)
            slStandartPeripheral.writeStandbyBrightness(value)
        }
    }
    
    func writeStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyTopCountKey, value: count)
        slStandartPeripheral.writeStandbyTopCount(count)
    }
    
    func writeStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyBotCountKey, value: count)
        slStandartPeripheral.writeStandbyBotCount(count)
    }
    
    private func initTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as! Int != 0
    }
    
    private func initBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as! Int != 0
    }
    
    private func initStepsCount(count: Int) {
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
    }
    
    private func initTopSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.topSensorCountKey, value: count)
    }
    
    private func initBotSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.botSensorCountKey, value: count)
    }
    
}

extension SlStandartViewModel: SlStandartPeripheralDelegate {
    
    func getWorkMode(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlStandartData.stairsWorkModeKey, value: mode.name)
        updateCell(for: stairsWorkModeCell, with: .middle)
    }
    
    func getTopSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.topSensorCountKey, value: count)
        updateCell(for: topSensorCountCell, with: .middle)
    }
    
    func getBotSensorCount(count: Int) {
        dataModel.setValue(key: SlStandartData.botSensorCountKey, value: count)
        updateCell(for: botSensorCountCell, with: .middle)
    }
    
    func getLedType(type: PeripheralDataElement) {
        dataModel.setValue(key: SlStandartData.controllerTypeKey, value: type.name)
        updateCell(for: controllerTypeCell, with: .middle)
        handleLedType(type: type as! SlStandartControllerType)
    }
    
    func getLedAdaptiveBrightnessState(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlStandartData.ledAdaptiveModeKey, value: mode.name)
        updateCell(for: ledAdaptiveCell, with: .middle)
        handleAdaptiveMode(mode: mode as! PeripheralLedAdaptiveMode)
    }
    
    func getStepsCount(count: Int) {
        dataModel.setValue(key: SlStandartData.stepsCountKey, value: count)
        updateCell(for: stepsCountCell, with: .middle)
    }
    
    func getStandbyState(state: Bool) {
        dataModel.setValue(key: SlStandartData.standbyStateKey, value: state)
        updateCell(for: standbyStateCell, with: .middle)
    }
    
    func getStandbyBrightness(brightness: Int) {
        dataModel.setValue(key: SlStandartData.standbyBrightnessKey, value: brightness)
        updateCell(for: standbyBrightnessCell, with: .middle)
    }
    
    func getStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyTopCountKey, value: count)
        updateCell(for: standbyTopCountCell, with: .middle)
    }
    
    func getStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlStandartData.standbyBotCountKey, value: count)
        updateCell(for: standbyBotCountCell, with: .middle)
    }
    
    func getTopSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerLightnessKey, value: lightness)
        updateCell(for: topTriggerLightnessCell, with: .middle)
    }
    
    func getBotSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerLightnessKey, value: lightness)
        updateCell(for: botTriggerLightnessCell, with: .middle)
    }
    
    func getTopSensorCurrentLightness(lightness: Int) {
        print("TOP CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlStandartData.topCurrentLightnessKey, value: lightness)
        updateCell(for: topCurrentLightnessCell, with: .none)
    }
    
    func getBotSensorCurrentLightness(lightness: Int) {
        print("BOT CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlStandartData.botCurrentLightnessKey, value: lightness)
        updateCell(for: botCurrentLightnessCell, with: .none)
    }
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: SlStandartData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: SlStandartData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlStandartData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: SlStandartData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlStandartData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlStandartData.ledTimeoutKey, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getAnimationMode(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlStandartData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .middle)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: SlStandartData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    // Unused
    func getSecondaryColor(_ color: UIColor) { }
    func getAnimationOffSpeed(speed: Int) { }
    func getAnimationStep(step: Int) { }
    func getAnimationDirection(direction: PeripheralDataElement) { }
    
}
