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
    
    func getIndexPath(forRow: PeripheralCell) -> IndexPath? {
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
                rows: [.buttonCell(key: BasePeripheralData.errorKey, title: "Error")])
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
    var rows: [PeripheralCell]
}

enum PeripheralCell: Equatable {
        
    case colorCell(key: String, title: String, initialValue : UIColor)
    case pickerCell(key: String, title: String, initialValue: String)
    case sliderCell(key: String, title: String, initialValue: Float, minValue: Float, maxValue: Float)
    case switchCell(key: String, title: String, initialValue: Bool)
    case stepperCell(key: String, title: String, initialValue: Double, minValue: Double, maxValue: Double)
    case buttonCell(key: String, title: String)
    
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
    
    var cellKey: String {
        switch self {
        case .colorCell(let key, _, _):         return key
        case .pickerCell(let key, _, _):        return key
        case .sliderCell(let key, _, _, _, _):  return key
        case .switchCell(let key, _, _):        return key
        case .stepperCell(let key, _, _, _, _): return key
        case .buttonCell(let key, _):           return key
        }
    }
    
    func cellValue(from model: PeripheralData) -> Any? {
        return model.getValue(key: cellKey)
    }
    
    var cellReuseID: String {
        switch self {
        case .colorCell:   return ColorTableViewCell.reuseIdentifier
        case .switchCell:  return SwitchTableViewCell.reuseIdentifier
        case .pickerCell:  return PickerTableViewCell.reuseIdentifier
        case .sliderCell:  return SliderTableViewCell.reuseIdentifier
        case .stepperCell: return StepperTableViewCell.reuseIdentifier
        case .buttonCell:  return ButtonTableViewCell.reuseIdentifier
        }
    }
    
    var nibName: String {
        switch self {
        case .colorCell:   return "ColorTableViewCell"
        case .switchCell:  return "SwitchTableViewCell"
        case .pickerCell:  return "PickerTableViewCell"
        case .sliderCell:  return "SliderTableViewCell"
        case .stepperCell: return "StepperTableViewCell"
        case .buttonCell:  return "ButtonTableViewCell"
        }
    }
    
    var cellClass: BaseTableViewCell.Type {
        switch self {
        case .colorCell:   return ColorTableViewCell.self
        case .pickerCell:  return PickerTableViewCell.self
        case .sliderCell:  return SliderTableViewCell.self
        case .switchCell:  return SwitchTableViewCell.self
        case .stepperCell: return StepperTableViewCell.self
        case .buttonCell:  return ButtonTableViewCell.self
        }
    }
    
    func configure(cell: BaseTableViewCell, with data: PeripheralData) {
        switch self {
        case .sliderCell(key: let key, title: let title, initialValue: let initialValue, minValue: let minValue, maxValue: let maxValue):
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = minValue
                cell.slider.maximumValue = maxValue
                cell.slider.value        = Float(data.getValue(key: key) as? Int ?? Int(initialValue))
                cell.titleLabel.text     = title
            }
        case .colorCell(key: let key, title: let title, initialValue: _):
            if let cell = cell as? ColorTableViewCell {
                cell.configure(title: title, value: data.getValue(key: key))
            }
        case .pickerCell(key: let key, title: let title, initialValue: let initialValue):
            if let cell = cell as? PickerTableViewCell {
                let dataValue = data.getValue(key: key) as? PeripheralDataElement
                cell.titleLabel.text = title
                cell.valueLabel.text = dataValue?.name ?? initialValue
            }
        case .switchCell(key: let key, title: let title, initialValue: let initialValue):
            if let cell = cell as? SwitchTableViewCell {
                cell.titleLabel.text = title
                cell.cellSwitch.isOn = data.getValue(key: key) as? Bool ?? initialValue
            }
        case .stepperCell(key: let key, title: let title, initialValue: let initialValue, minValue: let minValue, maxValue: let maxValue):
            if let cell = cell as? StepperTableViewCell {
                let dataValue = data.getValue(key: key) as? Int ?? Int(initialValue)
                cell.titleLabel.text = title
                cell.valueLabel.text = String(describing: dataValue)
                cell.stepper.value = Double(dataValue)
                cell.stepper.minimumValue = minValue
                cell.stepper.maximumValue = maxValue
            }
        case .buttonCell(key:_, title: let title):
            if let cell = cell as? ButtonTableViewCell {
                cell.button.setTitle(title, for: .normal)
            }
        }
    }
    
}
