//
//  PeripheralTableViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

struct PeripheralTableViewModel {
    var sections: [PeripheralSection]
    
    func getIndexPath(forRow: PeripheralRow) -> IndexPath? {
        if let section = sections.filter({ $0.rows.contains(forRow)}).first,
           let sectionIndex = sections.firstIndex(of: section),
           let rowIndex = sections[sectionIndex].rows.firstIndex(of: forRow) {
            return IndexPath.init(row: rowIndex, section: sectionIndex)
        }
        return nil
    }
    
    enum TableViewType: Int {
        case ready    = 1
        case setup    = 2
        case settings = 3
    }
}

extension PeripheralTableViewModel {
    static var errorSection: PeripheralSection {
        get {
            PeripheralSection.init(
                headerText: "Error",
                footerText: "Device error found",
                rows: [.error])
        }
    }
}

struct HiddenIndexPath {
    var section = [Int]()
    var row = [IndexPath]()
    
    mutating func clear() {
        section.removeAll()
        row.removeAll()
    }
}

struct PeripheralSection: Equatable {
    let headerText: String
    let footerText: String
    var rows: [PeripheralRow]
}

enum PeripheralRow: CaseIterable {
    case primaryColor
    case secondaryColor
    case randomColor
    case animationMode
    case animationDirection
    case animationOnSpeed
    case animationOffSpeed
    case animationStep
    case ledState
    case ledBrightness
    case ledTimeout
    case topSensorTriggerDistance
    case botSensorTriggerDistance
    case error
    
    func updateCell(in tableView: UITableView, with tableViewModel: PeripheralTableViewModel) {
        if let indexPath = tableViewModel.getIndexPath(forRow: self) {
            tableView.reloadRows(at: [indexPath], with: .middle)
            print("Reloading cell \(indexPath)")
        } else {
            tableView.reloadData()
            print("Reloading tableView")
        }
    }
    
    func getIndexPath(fromModel: PeripheralTableViewModel) -> IndexPath? {
        return fromModel.getIndexPath(forRow: self)
    }
    
    var name: String {
        switch self {
        case .primaryColor:             return "Primary"
        case .secondaryColor:           return "Secondary"
        case .randomColor:              return "Random color"
        case .animationMode:            return "Animation"
        case .animationDirection:       return "Direction"
        case .animationOnSpeed:         return "Speed"
        case .animationOffSpeed:        return "Animation off speed"
        case .animationStep:            return "Step"
        case .topSensorTriggerDistance: return "Top sensor trigger distance"
        case .botSensorTriggerDistance: return "Bot sensor trigger distance"
        case .ledState:                 return "Led state"
        case .ledBrightness:            return "Led brightness"
        case .ledTimeout:               return "Led timeout"
        case .error:                    return "Error"
        }
    }
    
    func cellValue(from model: PeripheralDataModel) -> Any? {
        switch self {
        case .primaryColor:             return model.primaryColor
        case .secondaryColor:           return model.secondaryColor
        case .randomColor:              return model.randomColor
        case .animationMode:            return model.animationMode?.name
        case .animationDirection:       return model.animationDirection?.name
        case .animationOnSpeed:         return model.animationOnSpeed.value
        case .animationOffSpeed:        return model.animationOffSpeed.value
        case .animationStep:            return model.animationStep.value
        case .topSensorTriggerDistance: return model.topSensorTriggerDistance.value
        case .botSensorTriggerDistance: return model.botSensorTriggerDistance.value
        case .ledState:                 return model.ledState
        case .ledBrightness:            return model.ledBrightness.value
        case .ledTimeout:               return model.ledTimeout.value
        case .error:                    return model.errorCode
        }
    }
    
    var cellReuseID: String {
        switch self {
        case .primaryColor:             return ColorTableViewCell.reuseIdentifier
        case .secondaryColor:           return ColorTableViewCell.reuseIdentifier
        case .randomColor:              return SwitchTableViewCell.reuseIdentifier
        case .animationMode:            return PickerTableViewCell.reuseIdentifier
        case .animationDirection:       return PickerTableViewCell.reuseIdentifier
        case .animationOnSpeed:         return SliderTableViewCell.reuseIdentifier
        case .animationOffSpeed:        return SliderTableViewCell.reuseIdentifier
        case .animationStep:            return StepperTableViewCell.reuseIdentifier
        case .topSensorTriggerDistance: return SliderTableViewCell.reuseIdentifier
        case .botSensorTriggerDistance: return SliderTableViewCell.reuseIdentifier
        case .ledState:                 return SwitchTableViewCell.reuseIdentifier
        case .ledBrightness:            return SliderTableViewCell.reuseIdentifier
        case .ledTimeout:               return StepperTableViewCell.reuseIdentifier
        case .error:                    return PickerTableViewCell.reuseIdentifier
        }
    }
    
    var nibName: String {
        switch self {
        case .primaryColor:             return "ColorTableViewCell"
        case .secondaryColor:           return "ColorTableViewCell"
        case .randomColor:              return "SwitchTableViewCell"
        case .animationMode:            return "PickerTableViewCell"
        case .animationDirection:       return "PickerTableViewCell"
        case .animationOnSpeed:         return "SliderTableViewCell"
        case .animationOffSpeed:        return "SliderTableViewCell"
        case .animationStep:            return "StepperTableViewCell"
        case .topSensorTriggerDistance: return "SliderTableViewCell"
        case .botSensorTriggerDistance: return "SliderTableViewCell"
        case .ledState:                 return "SwitchTableViewCell"
        case .ledBrightness:            return "SliderTableViewCell"
        case .ledTimeout:               return "StepperTableViewCell"
        case .error:                    return "PickerTableViewCell"
        }
    }
    
    var cellClass: BaseTableViewCell.Type {
        switch self {
        case .primaryColor:             return ColorTableViewCell.self
        case .secondaryColor:           return ColorTableViewCell.self
        case .randomColor:              return SwitchTableViewCell.self
        case .animationMode:            return PickerTableViewCell.self
        case .animationDirection:       return PickerTableViewCell.self
        case .animationOnSpeed:         return SliderTableViewCell.self
        case .animationOffSpeed:        return SliderTableViewCell.self
        case .animationStep:            return StepperTableViewCell.self
        case .topSensorTriggerDistance: return SliderTableViewCell.self
        case .botSensorTriggerDistance: return SliderTableViewCell.self
        case .ledState:                 return SwitchTableViewCell.self
        case .ledBrightness:            return SliderTableViewCell.self
        case .ledTimeout:               return StepperTableViewCell.self
        case .error:                    return PickerTableViewCell.self
        }
    }
    
    func setupCell(cell: BaseTableViewCell, with dataModel: PeripheralDataModel) {
        switch self {
        case .primaryColor:
            if let cell = cell as? ColorTableViewCell {
                cell.configure(title: self.name, value: dataModel.primaryColor)
            }
        case .secondaryColor:
            if let cell = cell as? ColorTableViewCell {
                cell.configure(title: self.name, value: dataModel.secondaryColor)
            }
        case .randomColor:
            if let cell = cell as? SwitchTableViewCell {
                cell.cellSwitch.isOn = dataModel.randomColor ?? false
                cell.titleLabel.text     = self.name.localized
            }
        case .animationMode:
            if let cell = cell as? PickerTableViewCell {
                cell.valueLabel.text = dataModel.animationMode?.name
                cell.titleLabel.text     = self.name.localized
            }
        case .animationDirection:
            if let cell = cell as? PickerTableViewCell {
                cell.valueLabel.text = dataModel.animationDirection?.name
                cell.titleLabel.text     = self.name.localized
            }
        case .animationOnSpeed:
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = Float(dataModel.animationOnSpeed.minValue ?? 0)
                cell.slider.maximumValue = Float(dataModel.animationOnSpeed.maxValue ?? 100)
                cell.slider.value        = Float(dataModel.animationOnSpeed.value ?? 0)
                cell.titleLabel.text     = self.name.localized
            }
        case .animationOffSpeed:
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = Float(dataModel.animationOffSpeed.minValue ?? 0)
                cell.slider.maximumValue = Float(dataModel.animationOffSpeed.maxValue ?? 100)
                cell.slider.value        = Float(dataModel.animationOnSpeed.value ?? 0)
                cell.titleLabel.text     = self.name.localized
            }
        case .animationStep:
            if let cell = cell as? StepperTableViewCell {
                cell.stepper.minimumValue = Double(dataModel.animationStep.minValue ?? 0)
                cell.stepper.maximumValue = Double(dataModel.animationStep.maxValue ?? 0)
                cell.stepper.value        = Double(dataModel.animationStep.value ?? 0)
                cell.titleLabel.text      = self.name.localized
                cell.valueLabel.text      = String(describing: dataModel.animationStep.value ?? 0)
            }
        case .ledState:
            if let cell = cell as? SwitchTableViewCell {
                cell.cellSwitch.isOn = dataModel.ledState ?? false
                cell.titleLabel.text = self.name.localized
            }
        case .ledBrightness:
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = Float(dataModel.ledBrightness.minValue ?? 0)
                cell.slider.maximumValue = Float(dataModel.ledBrightness.maxValue ?? 100)
                cell.slider.value        = Float(dataModel.ledBrightness.value ?? 0)
                cell.titleLabel.text     = self.name.localized
            }
        case .ledTimeout:
            if let cell = cell as? StepperTableViewCell {
                cell.stepper.minimumValue = Double(dataModel.ledTimeout.minValue ?? 0)
                cell.stepper.maximumValue = Double(dataModel.ledTimeout.maxValue ?? 10)
                cell.stepper.value        = Double(dataModel.ledTimeout.value ?? 0)
                cell.valueLabel.text      = String(describing: dataModel.ledTimeout.value ?? 0)
                cell.titleLabel.text      = self.name.localized
            }
        case .topSensorTriggerDistance:
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = Float(dataModel.topSensorTriggerDistance.minValue ?? 1)
                cell.slider.maximumValue = Float(dataModel.topSensorTriggerDistance.maxValue ?? 100)
                cell.slider.value        = Float(dataModel.topSensorTriggerDistance.value ?? 1)
                cell.titleLabel.text     = self.name.localized
            }
        case .botSensorTriggerDistance:
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = Float(dataModel.botSensorTriggerDistance.maxValue ?? 1)
                cell.slider.maximumValue = Float(dataModel.botSensorTriggerDistance.maxValue ?? 100)
                cell.slider.value        = Float(dataModel.botSensorTriggerDistance.value ?? 1)
                cell.titleLabel.text     = self.name.localized
            }
        case .error:
            if let cell = cell as? PickerTableViewCell {
                cell.titleLabel.text = self.name.localized
                cell.valueLabel.text = "Details".localized
                cell.backgroundColor = UIColor.SLRed
            }
        }
    }
}
