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

enum PeripheralRow: Int, CaseIterable {
    case primaryColor
    case secondaryColor
    case randomColor
    case animationMode
    case animationDirection
    case animationOnSpeed
    case animationOffSpeed
    case animationStep
    
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
        case .primaryColor:       return "Primary"
        case .secondaryColor:     return "Secondary"
        case .randomColor:        return "Random color"
        case .animationMode:      return "Animation"
        case .animationDirection: return "Direction"
        case .animationOnSpeed:   return "Speed"
        case .animationOffSpeed:  return "Animation off speed"
        case .animationStep:      return "Step"
        }
    }
    
    func cellValue(from model: TorcherePeripheralDataModel) -> Any? {
        switch self {
        case .primaryColor:       return model.primaryColor
        case .secondaryColor:     return model.secondaryColor
        case .randomColor:        return model.randomColor
        case .animationMode:      return model.animationMode?.name
        case .animationDirection: return model.animationDirection?.name
        case .animationOnSpeed:   return model.animationOnSpeed
        case .animationOffSpeed:  return model.animationOffSpeed
        case .animationStep:      return model.animationStep
        }
    }
    
    var cellReuseID: String {
        switch self {
        case .primaryColor:       return ColorTableViewCell.reuseIdentifier
        case .secondaryColor:     return ColorTableViewCell.reuseIdentifier
        case .randomColor:        return SwitchTableViewCell.reuseIdentifier
        case .animationMode:      return PickerTableViewCell.reuseIdentifier
        case .animationDirection: return PickerTableViewCell.reuseIdentifier
        case .animationOnSpeed:   return SliderTableViewCell.reuseIdentifier
        case .animationOffSpeed:  return SliderTableViewCell.reuseIdentifier
        case .animationStep:      return StepperTableViewCell.reuseIdentifier
        }
    }
    
    var nibName: String {
        switch self {
        case .primaryColor:       return "ColorTableViewCell"
        case .secondaryColor:     return "ColorTableViewCell"
        case .randomColor:        return "SwitchTableViewCell"
        case .animationMode:      return "PickerTableViewCell"
        case .animationDirection: return "PickerTableViewCell"
        case .animationOnSpeed:   return "SliderTableViewCell"
        case .animationOffSpeed:  return "SliderTableViewCell"
        case .animationStep:      return "StepperTableViewCell"
        }
    }
    
    var cellClass: BaseTableViewCell.Type {
        switch self {
        case .primaryColor:       return ColorTableViewCell.self
        case .secondaryColor:     return ColorTableViewCell.self
        case .randomColor:        return SwitchTableViewCell.self
        case .animationMode:      return PickerTableViewCell.self
        case .animationDirection: return PickerTableViewCell.self
        case .animationOnSpeed:   return SliderTableViewCell.self
        case .animationOffSpeed:  return SliderTableViewCell.self
        case .animationStep:      return StepperTableViewCell.self
        }
    }
}
