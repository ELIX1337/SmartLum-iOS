//
//  SlProViewModel.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SlProViewModel: PeripheralViewModel {
    
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
            if let color = self.dataModel.getValue(key: SlProData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    var slProPeripheral: SlProPeripheral! {
        get { return (super.basePeripheral as! SlProPeripheral) }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral as! SlProPeripheral, delegate, selected)
        slProPeripheral.delegate = self
        self.tableView = withTableView
        self.onCellSelected = selected
        self.dataModel = SlProData(values: [:])
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
                    headerText: "peripheral_sl_pro_led_section_header".localized,
                    footerText: "peripheral_sl_pro_led_section_footer".localized,
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
            key: SlProData.primaryColorKey,
            title: "peripheral_sl_pro_color_cell_title".localized,
            initialValue: UIColor.white, callback: { _ in })
        randomColorCell = .switchCell(
            key: SlProData.randomColorKey,
            title: "peripheral_sl_pro_random_color_cell_title".localized,
            initialValue: false,
            callback: { self.writeRandomColor(state: $0) })
    }
    
    private func initLedSection() {
        ledStateCell = .switchCell(
            key: SlProData.ledStateKey,
            title: "peripheral_led_state_cell_title".localized,
            initialValue: false,
            callback: { self.writeLedState(state: $0) })
        ledBrightnessCell = .sliderCell(
            key: SlProData.ledBrightnessKey,
            title: "peripheral_led_brightness_cell_title".localized,
            initialValue: Float(SlProData.ledMinBrightness),
            minValue: Float(SlProData.ledMinBrightness),
            maxValue: Float(SlProData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeLedBrightness(value: Int($0)) })
        ledTimeoutCell = .stepperCell(
            key: SlProData.ledTimeoutKey,
            title: "peripheral_led_timeout_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlProData.ledMinTimeout),
            maxValue: Double(SlProData.ledMaxTimeout),
            callback: { self.writeLedTimeout(timeout: Int($0)) })
    }
    
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: SlProData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: "")
        animationSpeedCell = .sliderCell(
            key: SlProData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(SlProData.animationMinSpeed),
            minValue: Float(SlProData.animationMinSpeed),
            maxValue: Float(SlProData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { self.writeAnimationSpeed(speed: Int($0)) })
    }
    
    private func initSettingsSection() {
        topTriggerDistanceCell = .sliderCell(
            key: SlProData.topTriggerDistanceKey,
            title: "peripheral_sl_pro_top_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlProData.sensorMinDistance),
            minValue: Float(SlProData.sensorMinDistance),
            maxValue: Float(SlProData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerDistance(value: Int($0)) })
        botTriggerDistanceCell = .sliderCell(
            key: SlProData.botTriggerDistanceKey,
            title: "peripheral_sl_pro_bot_sensor_trigger_distance_cell_title".localized,
            initialValue: Float(SlProData.sensorMinDistance),
            minValue: Float(SlProData.sensorMinDistance),
            maxValue: Float(SlProData.sensorMaxDistance),
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerDistance(value: Int($0)) })
        topTriggerLightnessCell = .sliderCell(
            key: SlProData.topTriggerLightnessKey,
            title: "peripheral_sl_pro_top_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeTopTriggerLightness(value: Int($0)) })
        botTriggerLightnessCell = .sliderCell(
            key: SlProData.botTriggerLightnessKey,
            title: "peripheral_sl_pro_bot_sensor_trigger_lightness_cell_title".localized,
            initialValue: 0,
            minValue: 0,
            maxValue: 100,
            leftIcon: nil,
            rightIcon: nil,
            showValue: true,
            callback: { self.writeBotTriggerLightness(value: Int($0)) })
        topCurrentDistanceCell = .infoCell(
            key: SlProData.topCurrentDistanceKey,
            titleText: "peripheral_sl_pro_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        botCurrentDistanceCell = .infoCell(
            key: SlProData.topCurrentDistanceKey,
            titleText: "peripheral_sl_pro_top_current_distance_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: nil)
        stairsWorkModeCell = .pickerCell(
            key: SlProData.stairsWorkModeKey,
            title: "peripheral_sl_pro_stairs_work_mode_cell_title".localized,
            initialValue: PeripheralStairsWorkMode.bySensors.name)
        controllerTypeCell = .infoCell(
            key: SlProData.controllerTypeKey,
            titleText: "peripheral_sl_pro_controller_type_cell_title".localized,
            detailText: "",
            image: nil,
            accessory: UITableViewCell.AccessoryType.none)
        ledAdaptiveCell = .pickerCell(
            key: SlProData.ledAdaptiveModeKey,
            title: "peripheral_sl_pro_adaptive_brightness_cell_title".localized,
            initialValue: PeripheralLedAdaptiveMode.off.name)
        stepsCountCell = .stepperCell(
            key: SlProData.stepsCountKey,
            title: "peripheral_sl_pro_steps_count_cell".localized,
            initialValue: Double(SlProData.sensorMinCount),
            minValue: Double(SlProData.stepsMinCount),
            maxValue: Double(SlProData.stepsMaxCount),
            callback: { self.writeStepsCount(count: Int($0)) })
        topSensorCountCell = .stepperCell(
            key: SlProData.topSensorCountKey,
            title: "peripheral_sl_pro_top_sensor_count_cell_title".localized,
            initialValue: Double(SlProData.sensorMinCount),
            minValue: Double(SlProData.sensorMinCount),
            maxValue: Double(SlProData.sensorMaxCount),
            callback: { self.writeTopSensorCount(count: Int($0)) })
        botSensorCountCell = .stepperCell(
            key: SlProData.topSensorCountKey,
            title: "peripheral_sl_pro_bot_sensor_count_cell_title".localized,
            initialValue: 0,
            minValue: Double(SlProData.sensorMinCount),
            maxValue: Double(SlProData.sensorMaxCount),
            callback: { self.writeBotSensorCount(count: Int($0)) })
        standbyStateCell = .switchCell(
            key: SlProData.standbyStateKey,
            title: "peripheral_sl_pro_standby_state".localized,
            initialValue: false,
            callback: { self.writeStandbyState(state: $0) })
        standbyBrightnessCell = .sliderCell(
            key: SlProData.standbyBrightnessKey,
            title: "peripheral_sl_pro_standby_brightness".localized,
            initialValue: 0,
            minValue: Float(SlProData.ledMinBrightness),
            maxValue: Float(SlProData.ledMaxBrightness),
            leftIcon: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.largeScale),
            rightIcon: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.largeScale),
            showValue: false,
            callback: { self.writeStandbyBrightness(value: Int($0)) })
        standbyTopCountCell = .stepperCell(
            key: SlProData.standbyTopCountKey,
            title: "peripheral_sl_pro_standby_top_count".localized,
            initialValue: 0,
            minValue: Double(SlProData.standbyMinCount),
            maxValue: Double(SlProData.standbyMaxCount),
            callback: { self.writeStandbyTopCount(count: Int($0)) })
        standbyBotCountCell = .stepperCell(
            key: SlProData.standbyBotCountKey,
            title: "peripheral_sl_pro_standby_bot_count".localized,
            initialValue: 0,
            minValue: Double(SlProData.standbyMinCount),
            maxValue: Double(SlProData.standbyMaxCount),
            callback: { self.writeStandbyBotCount(count: Int($0)) })
        resetToFactoryCell = .buttonCell(
            key: BasePeripheralData.factoryResetKey,
            title: "peripheral_reset_to_factory_cell_title".localized,
            callback: { self.onCellSelected(self.resetToFactoryCell) })
        topCurrentLightnessCell = .infoCell(
            key: SlProData.topCurrentLightnessKey,
            titleText: "peripheral_sl_pro_top_current_lightness_cell_title".localized,
            detailText: nil,
            image: nil,
            accessory: nil)
        botCurrentLightnessCell = .infoCell(
            key: SlProData.botCurrentLightnessKey,
            titleText: "peripheral_sl_pro_bot_current_lightness_cell_title".localized,
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
    
    func writePrimaryColor(_ color: UIColor) {
        if (dataModel.getValue(key: SlProData.primaryColorKey) as? UIColor != color) {
            slProPeripheral.writePrimaryColor(color)
            dataModel.setValue(key: SlProData.primaryColorKey, value: color)
            updateCell(for: primaryColorCell, with: .none)
        }
    }
    
    func writeRandomColor(state: Bool) {
        dataModel.setValue(key: SlProData.randomColorKey, value: state)
        slProPeripheral.writeRandomColor(state)
    }
    
    func writeAnimationMode(mode: SlProAnimations) {
        guard mode.name != dataModel.getValue(key: SlProData.animationModeKey) as! String else { return }
        dataModel.setValue(key: SlProData.animationModeKey, value: mode.name)
        slProPeripheral.writeAnimationMode(mode)
        updateCell(for: animationModeCell, with: .none)
    }
    
    func writeLedType(type: SlProControllerType) {
        dataModel.setValue(key: SlProData.controllerTypeKey, value: type)
        slProPeripheral.writeLedType(type)
        updateCell(for: controllerTypeCell, with: .none)
        handleLedType(type: type)
    }
    
    func writeLedState(state: Bool) {
        dataModel.setValue(key: SlProData.ledStateKey, value: state)
        slProPeripheral.writeLedState(state)
    }
    
    func writeLedBrightness(value: Int) {
        if (dataModel.getValue(key: SlProData.ledBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlProData.ledBrightnessKey, value: value)
            slProPeripheral.writeLedBrightness(value)
        }
    }
    
    func writeLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlProData.ledTimeoutKey, value: timeout)
        slProPeripheral.writeLedTimeout(Int(timeout))
    }
    
    func writeLedAdaptiveBrightnessMode(mode: PeripheralLedAdaptiveMode) {
        dataModel.setValue(key: SlProData.ledAdaptiveModeKey, value: mode.name)
        slProPeripheral.writeLedAdaptiveBrightnessState(mode)
        updateCell(for: ledAdaptiveCell, with: .none)
        handleAdaptiveMode(mode: mode)
    }
    
    func writeAnimationSpeed(speed: Int) {
        if (dataModel.getValue(key: SlProData.animationSpeedKey) as? Int != speed) {
            dataModel.setValue(key: SlProData.animationSpeedKey, value: speed)
            slProPeripheral.writeAnimationOnSpeed(speed)
        }
    }
    
    func writeTopTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlProData.topTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlProData.topTriggerDistanceKey, value: value)
            slProPeripheral.writeTopSensorTriggerDistance(value)
        }
    }
    
    func writeBotTriggerDistance(value: Int) {
        if (dataModel.getValue(key: SlProData.botTriggerDistanceKey) as? Int != value) {
            dataModel.setValue(key: SlProData.botTriggerDistanceKey, value: value)
            slProPeripheral.writeBotSensorTriggerDistance(value)
        }
    }
    
    func writeTopTriggerLightness(value: Int) {
        dataModel.setValue(key: SlProData.topTriggerLightnessKey, value: value)
        slProPeripheral.writeTopSensorLightness(value)
    }
    
    func writeBotTriggerLightness(value: Int) {
        dataModel.setValue(key: SlProData.botTriggerLightnessKey, value: value)
        slProPeripheral.writeBotSensorLightness(value)
    }
    
    func writeStairsWorkMode(mode: PeripheralStairsWorkMode) {
        dataModel.setValue(key: SlProData.stairsWorkModeKey, value: mode.name)
        slProPeripheral.writeStairsWorkMode(mode)
        updateCell(for: stairsWorkModeCell, with: .none)
    }
    
    func writeStepsCount(count: Int) {
        dataModel.setValue(key: SlProData.stepsCountKey, value: count)
        slProPeripheral.writeStepsCount(count)
    }
    
    func writeTopSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.topSensorCountKey, value: count)
        slProPeripheral.writeTopSensorCount(count)
    }
    
    func writeBotSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.botSensorCountKey, value: count)
        slProPeripheral.writeBotSensorCount(count)
    }
    
    func writeStandbyState(state: Bool) {
        dataModel.setValue(key: SlProData.standbyStateKey, value: state)
        slProPeripheral.writeStandbyState(state)
    }
    
    func writeStandbyBrightness(value: Int) {
        if (dataModel.getValue(key: SlProData.standbyBrightnessKey) as? Int != value) {
            dataModel.setValue(key: SlProData.standbyBrightnessKey, value: value)
            slProPeripheral.writeStandbyBrightness(value)
        }
    }
    
    func writeStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlProData.standbyTopCountKey, value: count)
        slProPeripheral.writeStandbyTopCount(count)
    }
    
    func writeStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlProData.standbyBotCountKey, value: count)
        slProPeripheral.writeStandbyBotCount(count)
    }
    
    private func initTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlProData.topTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.botTriggerDistanceKey) as! Int != 0
    }
    
    private func initBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlProData.botTriggerDistanceKey, value: distance)
        //readyToWriteInitData = dataModel.getValue(key: SlStandartData.topTriggerDistanceKey) as! Int != 0
    }
    
    private func initStepsCount(count: Int) {
        dataModel.setValue(key: SlProData.stepsCountKey, value: count)
    }
    
    private func initTopSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.topSensorCountKey, value: count)
    }
    
    private func initBotSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.botSensorCountKey, value: count)
    }
    
}

extension SlProViewModel: SlProPeripheralDelegate {
    
    func getWorkMode(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlProData.stairsWorkModeKey, value: mode.name)
        updateCell(for: stairsWorkModeCell, with: .middle)
    }
    
    func getTopSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.topSensorCountKey, value: count)
        updateCell(for: topSensorCountCell, with: .middle)
    }
    
    func getBotSensorCount(count: Int) {
        dataModel.setValue(key: SlProData.botSensorCountKey, value: count)
        updateCell(for: botSensorCountCell, with: .middle)
    }
    
    func getLedType(type: PeripheralDataElement) {
        dataModel.setValue(key: SlProData.controllerTypeKey, value: type.name)
        updateCell(for: controllerTypeCell, with: .middle)
        handleLedType(type: type as! SlProControllerType)
    }
    
    func getLedAdaptiveBrightnessState(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlProData.ledAdaptiveModeKey, value: mode.name)
        updateCell(for: ledAdaptiveCell, with: .middle)
        handleAdaptiveMode(mode: mode as! PeripheralLedAdaptiveMode)
    }
    
    func getStepsCount(count: Int) {
        dataModel.setValue(key: SlProData.stepsCountKey, value: count)
        updateCell(for: stepsCountCell, with: .middle)
    }
    
    func getStandbyState(state: Bool) {
        dataModel.setValue(key: SlProData.standbyStateKey, value: state)
        updateCell(for: standbyStateCell, with: .middle)
    }
    
    func getStandbyBrightness(brightness: Int) {
        dataModel.setValue(key: SlProData.standbyBrightnessKey, value: brightness)
        updateCell(for: standbyBrightnessCell, with: .middle)
    }
    
    func getStandbyTopCount(count: Int) {
        dataModel.setValue(key: SlProData.standbyTopCountKey, value: count)
        updateCell(for: standbyTopCountCell, with: .middle)
    }
    
    func getStandbyBotCount(count: Int) {
        dataModel.setValue(key: SlProData.standbyBotCountKey, value: count)
        updateCell(for: standbyBotCountCell, with: .middle)
    }
    
    func getTopSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: SlProData.topTriggerLightnessKey, value: lightness)
        updateCell(for: topTriggerLightnessCell, with: .middle)
    }
    
    func getBotSensorTriggerLightness(lightness: Int) {
        dataModel.setValue(key: SlProData.botTriggerLightnessKey, value: lightness)
        updateCell(for: botTriggerLightnessCell, with: .middle)
    }
    
    func getTopSensorCurrentLightness(lightness: Int) {
        print("TOP CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlProData.topCurrentLightnessKey, value: lightness)
        updateCell(for: topCurrentLightnessCell, with: .none)
    }
    
    func getBotSensorCurrentLightness(lightness: Int) {
        print("BOT CURRENT LIGHTNESS - \(lightness)")
        dataModel.setValue(key: SlProData.botCurrentLightnessKey, value: lightness)
        updateCell(for: botCurrentLightnessCell, with: .none)
    }
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: SlProData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: SlProData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .middle)
    }
    
    func getTopSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlProData.topTriggerDistanceKey, value: distance)
        updateCell(for: topTriggerDistanceCell, with: .middle)
    }
    
    func getBotSensorTriggerDistance(distance: Int) {
        dataModel.setValue(key: SlProData.botTriggerDistanceKey, value: distance)
        updateCell(for: botTriggerDistanceCell, with: .middle)
    }
    
    func getLedState(state: Bool) {
        dataModel.setValue(key: SlProData.ledStateKey, value: state)
        updateCell(for: ledStateCell, with: .middle)
    }
    
    func getLedBrightness(brightness: Int) {
        dataModel.setValue(key: SlProData.ledBrightnessKey, value: brightness)
        updateCell(for: ledBrightnessCell, with: .middle)
    }
    
    func getLedTimeout(timeout: Int) {
        dataModel.setValue(key: SlProData.ledTimeoutKey, value: timeout)
        updateCell(for: ledTimeoutCell, with: .middle)
    }
    
    func getAnimationMode(mode: PeripheralDataElement) {
        dataModel.setValue(key: SlProData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .middle)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: SlProData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    // Unused
    func getSecondaryColor(_ color: UIColor) { }
    func getAnimationOffSpeed(speed: Int) { }
    func getAnimationStep(step: Int) { }
    func getAnimationDirection(direction: PeripheralDataElement) { }
    
}
