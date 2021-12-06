//
//  FlClassic.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class FlClassicViewModel: PeripheralViewModel {
        
    var peripheral: FlClassicPeripheral! {
        get { return (super.basePeripheral as! FlClassicPeripheral) }
    }
    
    var primaryColorCell:       CellModel!
    var secondaryColorCell:     CellModel!
    var randomColorCell:        CellModel!
    var animationModeCell:      CellModel!
    var animationSpeedCell:     CellModel!
    var animationDirectionCell: CellModel!
    var animationStepCell:      CellModel!
        
    // Public variables for using in viewController
    var primaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.primaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    var secondaryColor: UIColor {
        get {
            if let color = dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor {
                return color
            }
            return UIColor.white
        }
    }
    
    override init(_ withTableView: UITableView,
                  _ withPeripheral: BasePeripheral,
                  _ delegate: PeripheralViewModelDelegate,
                  _ selected: @escaping (CellModel) -> Void) {
        super.init(withTableView, withPeripheral, delegate, selected)
        peripheral.delegate = self
        dataModel = FlClassicData.init(values: [:])
        initColorSection()
        initAnimationSection()
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
    
    private func initColorSection() {
        primaryColorCell = .colorCell(
            key: FlClassicData.primaryColorKey,
            title: "peripheral_primary_color_cell_title".localized,
            initialValue: primaryColor,
            callback: { _ in })
        secondaryColorCell = .colorCell(
            key: FlClassicData.secondaryColorKey,
            title: "peripheral_secondary_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.secondaryColorKey) as? UIColor ?? UIColor.SLWhite,
            callback: { _ in })
        randomColorCell = .switchCell(
            key: FlClassicData.randomColorKey,
            title: "peripheral_random_color_cell_title".localized,
            initialValue: dataModel.getValue(key: FlClassicData.randomColorKey) as? Bool ?? false,
            callback: { self.writeRandomColor(state: $0) })
    }
    
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
    
    // Updating tableView depending selected animation
    private func handleAnimation(animation: FlClassicAnimations) {
        tableView.performBatchUpdates( {
            showAllCells(inModel: readyTableViewModel!)
            switch animation {
            case .tetris:
                hideCells(cells: [animationStepCell], inModel: readyTableViewModel!)
                break
            case .wave:
                hideCells(cells: [randomColorCell], inModel: readyTableViewModel!)
                break
            case .transfusion:
                hideCells(cells: [animationStepCell, animationDirectionCell], inModel: readyTableViewModel!)
                break
            case .rainbowTransfusion:
                hideCells(cells: [animationStepCell, animationDirectionCell], inModel: readyTableViewModel!)
                break
            case .rainbow:
                hideCells(cells: [animationStepCell], inModel: readyTableViewModel!)
                break
            case .static:
                hideCells(cells: [animationStepCell, animationSpeedCell, animationDirectionCell, secondaryColorCell, randomColorCell], inModel: readyTableViewModel!)
                break
            }
            let randonColorState = dataModel.getValue(key: FlClassicData.randomColorKey) as! Bool
            handleRandomColor(state: randonColorState)
        }, completion: nil)
    }
    
    private func handleRandomColor(state: Bool) {
        state ? hideCells(cells: [primaryColorCell, secondaryColorCell], inModel: readyTableViewModel!) :
         showCells(cells: [primaryColorCell, secondaryColorCell], inModel: readyTableViewModel!)
    }
    
    // Public API
    public func writePrimaryColor(color: UIColor) {
        peripheral.writePrimaryColor(color)
        dataModel.setValue(key: FlClassicData.primaryColorKey, value: color)
        updateCell(for: primaryColorCell, with: .none)
    }
    
    public func writeSecondaryColor(color: UIColor) {
        peripheral.writeSecondaryColor(color)
        dataModel.setValue(key: FlClassicData.secondaryColorKey, value: color)
        updateCell(for: secondaryColorCell, with: .none)
    }
    
    public func writeRandomColor(state: Bool) {
        peripheral.writeRandomColor(state)
        dataModel.setValue(key: FlClassicData.randomColorKey, value: state)
        updateCell(for: randomColorCell, with: .none)
        handleRandomColor(state: state)
    }
    
    public func writeAnimationMode(mode: FlClassicAnimations) {
        guard mode.name != dataModel.getValue(key: FlClassicData.animationModeKey) as! String else {
            return
        }
        peripheral.writeAnimationMode(mode)
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .none)
        handleAnimation(animation: mode)
    }
    
    public func writeAnimationDirection(direction: PeripheralAnimationDirections) {
        peripheral.writeAnimationDirection(direction)
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction)
        updateCell(for: animationDirectionCell, with: .none)
    }
    
    public func writeAnimationOnSpeed(speed: Int) {
        peripheral.writeAnimationOnSpeed(speed)
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .none)
    }
    
    public func writeAnimationStep(step: Int) {
        peripheral.writeAnimationStep(step)
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        updateCell(for: animationStepCell, with: .none)
    }
    
}

// Data from peripheral
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
    
    func getAnimationMode(mode: PeripheralDataElement) {
        dataModel.setValue(key: FlClassicData.animationModeKey, value: mode.name)
        updateCell(for: animationModeCell, with: .middle)
        handleAnimation(animation: mode as! FlClassicAnimations)
    }
    
    func getAnimationOnSpeed(speed: Int) {
        dataModel.setValue(key: FlClassicData.animationSpeedKey, value: speed)
        updateCell(for: animationSpeedCell, with: .middle)
    }
        
    func getAnimationDirection(direction: PeripheralDataElement) {
        dataModel.setValue(key: FlClassicData.animationDirectionKey, value: direction.name)
        updateCell(for: animationDirectionCell, with: .middle)
    }
    
    func getAnimationStep(step: Int) {
        dataModel.setValue(key: FlClassicData.animationStepKey, value: step)
        updateCell(for: animationStepCell, with: .middle)
    }
    
    // Unused
    func getAnimationOffSpeed(speed: Int) { }

}
