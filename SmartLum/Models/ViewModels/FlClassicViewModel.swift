//
//  FlClassic.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

// ViewModel устройства FL-Classic
class FlClassicViewModel: PeripheralViewModel {
     
    // Делаем downcast BasePeripheral в FlClassicPeripheral
    var peripheral: FlClassicPeripheral! {
        get { return (super.basePeripheral as! FlClassicPeripheral) }
    }
    
    // Заранее декларируем ячейки для нашей tableView
    var primaryColorCell:       CellModel!
    var secondaryColorCell:     CellModel!
    var randomColorCell:        CellModel!
    var animationModeCell:      CellModel!
    var animationSpeedCell:     CellModel!
    var animationDirectionCell: CellModel!
    var animationStepCell:      CellModel!
        
    // Публичные переменные для использования во ViewController'е
    // Используются чтобы инициализировать ColorPicker
    var primaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.primaryColorKey) as? UIColor {
                return color
            }
            // Дефолтное значение
            return UIColor.white
        }
    }
    
    var secondaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor {
                return color
            }
            // Дефолтное значение
            return UIColor.white
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        peripheral.delegate = self
        // dataModel - хранит значения полученные с устройства в формате ключ-значение
        //dataModel = FlClassicData.init(values: [:])
        dataModel = PeripheralData.init(values: [:], peripheralType: .FlClassic)
        initColorSection()
        initAnimationSection()
        // Инициализируем нашу TableView в родительском классе
        readyTableViewModel = TableViewModel(
            sections: [
                SectionModel(
                    headerText: "peripheral_color_section_header".localized,
                    footerText: "peripheral_color_section_footer".localized,
                    rows: [primaryColorCell, secondaryColorCell, randomColorCell]),
                SectionModel(
                    headerText: "peripheral_animation_section_header".localized,
                    footerText: "peripheral_animation_section_footer".localized,
                    rows: [animationModeCell, animationSpeedCell, animationDirectionCell, animationStepCell])
            ], type: .ready)
    }
    
    // Функция инициализации секции с цветами
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: FlClassicData.primaryColorKey,
            title: "peripheral_primary_color_cell_title".localized,
            initialValue: primaryColor,
            // callBack пустой, так как он обрабатывается во ViewController'e
            callback: { _ in })
        secondaryColorCell = .colorCell(
            key: FlClassicData.secondaryColorKey,
            title: "peripheral_secondary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor ?? UIColor.SLWhite,
            // callBack пустой, так как он обрабатывается во ViewController'e
            callback: { _ in })
        randomColorCell = .switchCell(
            key: FlClassicData.randomColorKey,
            title: "peripheral_random_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.randomColorKey) as? Bool ?? false,
            callback: { self.writeRandomColor(state: $0) })
    }
    
    // Функция инициализации секции с анимациями
    private func initAnimationSection() {
        animationModeCell = .pickerCell(
            key: FlClassicData.animationModeKey,
            title: "peripheral_animation_mode_cell_title".localized,
            initialValue: "")
        animationSpeedCell = .sliderCell(
            key: FlClassicData.animationSpeedKey,
            title: "peripheral_animation_speed_cell_title".localized,
            initialValue: Float(dataModel.getValue(key: FlClassicData.animationSpeedKey) as? Int ?? 0),
            minValue: Float(FlClassicData.animationMinSpeed),
            maxValue: Float(FlClassicData.animationMaxSpeed),
            leftIcon: nil,
            rightIcon: nil,
            showValue: false,
            callback: { speed in
                self.writeAnimationOnSpeed(speed: Int(speed))
                self.dataModel.setValue(key: FlClassicData.animationSpeedKey, value: Int(speed))
            })
        animationDirectionCell = .pickerCell(
            key: FlClassicData.animationDirectionKey,
            title: "peripheral_animation_direction_cell_title".localized,
            initialValue: "")
        animationStepCell = .stepperCell(
            key: FlClassicData.animationStepKey,
            title: "peripheral_animation_step_cell_title".localized,
            initialValue: Double(FlClassicData.animationMinStep),
            minValue: Double(FlClassicData.animationMinStep),
            maxValue: Double(FlClassicData.animationMaxStep),
            callback: { self.writeAnimationStep(step: Int($0)) })
    }
    
    /// Тупорылая и прямолинейная функция, которая скрывает/показывает ячейки в зависимости от выбранного режима анимации.
    /// Быстро, дешево.
    /// Очевидно, что это нужно делать поумнее.
    /// Например, в Android каждая анимация описана как тип данных (enum) и имеет поле supportingSettings от которого мы и узнаем, какие настройки нужно выводить на экран
    private func handleAnimation(animation: FlClassicAnimations) {
        tableView.performBatchUpdates( {
            // Обнуляем скрытые ячейки
            showAllCells(inModel: readyTableViewModel!)
            let randonColorState = dataModel.getValue(key: FlClassicData.randomColorKey) as! Bool
            // Перебираем
            switch animation {
            case .tetris:
                hideCells(cells: [animationStepCell], inModel: readyTableViewModel!)
                handleRandomColor(state: randonColorState)
                break
            case .wave:
                hideCells(cells: [randomColorCell], inModel: readyTableViewModel!)
                break
            case .transfusion:
                hideCells(cells: [animationStepCell, animationDirectionCell], inModel: readyTableViewModel!)
                handleRandomColor(state: randonColorState)
                break
            case .rainbowTransfusion:
                hideCells(cells: [primaryColorCell, secondaryColorCell, randomColorCell, animationStepCell, animationDirectionCell], inModel: readyTableViewModel!)
                break
            case .rainbow:
                hideCells(cells: [primaryColorCell, secondaryColorCell, randomColorCell, animationStepCell], inModel: readyTableViewModel!)
                break
            case .static:
                hideCells(cells: [animationStepCell, animationSpeedCell, animationDirectionCell, secondaryColorCell, randomColorCell], inModel: readyTableViewModel!)
                break
            }

        }, completion: nil)
    }
    
    /// Если включен RandomColor, то скрываем ячейки PrimaryColor и SecondaryColor
    private func handleRandomColor(state: Bool) {
        state ? hideCells(cells: [primaryColorCell, secondaryColorCell], inModel: readyTableViewModel!) :
         showCells(cells: [primaryColorCell, secondaryColorCell], inModel: readyTableViewModel!)
    }
    
    /// Публичный метод для записи primaryColor
    public func writePrimaryColor(color: UIColor) {
        peripheral.writePrimaryColor(color)
        // Обновляем данные в dataModel
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        // Перезагружаем соответствующую ячейку
        updateCell(for: primaryColorCell, with: .none)
    }
    
    /// Публичный метод для записи secondaryColor
    public func writeSecondaryColor(color: UIColor) {
        peripheral.writeSecondaryColor(color)
        // Обновляем данные в dataModel
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        // Перезагружаем соответствующую ячейку
        updateCell(for: secondaryColorCell, with: .none)
    }
    
    /// Публичный метод для записи randomColor
    public func writeRandomColor(state: Bool) {
        peripheral.writeRandomColor(state)
        // Обновляем данные в dataModel
        dataModel.setValue(key: FlClassicData.randomColorKey, value: state)
        // Перезагружаем соответствующую ячейку
        updateCell(for: randomColorCell, with: .none)
        // Скрываем или показываем primaryColor и secondaryColor
        handleRandomColor(state: state)
    }
    
    /// Публичный метод для записи режима анимации
    public func writeAnimationMode(mode: FlClassicAnimations) {
        guard mode.name != dataModel.getValue(key: FlClassicData.animationModeKey) as! String else {
            return
        }
        peripheral.writeAnimationMode(mode)
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .none)
        handleAnimation(animation: mode)
    }
    
    /// Публичный метод для направления анимации
    public func writeAnimationDirection(direction: PeripheralAnimationDirections) {
        peripheral.writeAnimationDirection(direction)
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        updateCell(for: animationDirectionCell, with: .none)
    }
    
    /// Публичный метод для записи скорости анимации
    public func writeAnimationOnSpeed(speed: Int) {
        peripheral.writeAnimationOnSpeed(speed)
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .none)
    }
    
    /// Публичный метод для записи шага анимации
    public func writeAnimationStep(step: Int) {
        peripheral.writeAnimationStep(step)
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        updateCell(for: animationStepCell, with: .none)
    }
    
}

/// Методы делегата периферийного устройства (прием данных)
extension FlClassicViewModel: FlClassicPeripheralDelegate {
    
    func getPrimaryColor(_ color: UIColor) {
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .middle)
    }
    
    func getSecondaryColor(_ color: UIColor) {
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        updateCell(for: secondaryColorCell, with: .middle)
    }
    
    func getRandomColor(_ state: Bool) {
        dataModel.setValue(key: FlClassicData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .middle)
        handleRandomColor(state: state)
    }
    
    func getAnimationMode(mode: PeripheralDataModel) {
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .middle)
        handleAnimation(animation: mode as! FlClassicAnimations)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    func getAnimationDirection(direction: PeripheralDataModel) {
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction.name)
        updateCell(for: animationDirectionCell, with: .middle)
    }
    
    func getAnimationStep(step: Int) {
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        updateCell(for: animationStepCell, with: .middle)
    }
    
    // Не используется
    func getAnimationOffSpeed(speed: Int) { }

}
