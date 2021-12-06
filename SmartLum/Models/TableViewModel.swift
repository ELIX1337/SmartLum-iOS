//
//  TableViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

struct TableViewModel: Equatable {
    var sections: [SectionModel]
    var type: TableViewModel.TableViewType
    
    func getIndexPath(forRow: CellModel) -> IndexPath? {
        if let section = sections.filter({ $0.rows.contains(forRow)}).first,
           let sectionIndex = sections.firstIndex(of: section),
           let rowIndex = sections[sectionIndex].rows.firstIndex(of: forRow) {
            return IndexPath.init(row: rowIndex, section: sectionIndex)
        }
        return nil
    }
    
    func getSectionByKey(_ key: String) -> SectionModel? {
        return sections.filter{ $0.key == key }.first
    }
    
    mutating func deleteCell(indexPath: IndexPath) {
        sections[indexPath.section].rows.remove(at: indexPath.row)
    }
    
    mutating func insertCell(cell: CellModel, inSectionByKey: String, at: Int) {
        guard let sectionKey = (sections.firstIndex { $0.key == inSectionByKey }) else { fatalError("Cannot find section with key \(inSectionByKey)") }
        sections[sectionKey].rows.insert(cell, at: at)
    }
    
    enum TableViewType: Int {
        case ready    = 1
        case setup    = 2
        case settings = 3
    }
}

extension TableViewModel {
    
    static var KEY_NOTICE_SECTION: String { get { "peripheral_notice_section_key" } }
    static var KEY_NOTICE_DETAIL_SECTION: String { get { "peripheral_notice_detail_section_key" } }
    
    static func createNoticeSection(withRows: [CellModel]?) -> SectionModel {
        return SectionModel(
            key: KEY_NOTICE_SECTION,
            headerText: "peripheral_notice_section_header".localized,
            footerText: "peripheral_notice_section_footer".localized,
            rows: withRows ?? [])
    }
    
    static func createNoticeDetailSection(withRows: [CellModel]?) -> SectionModel {
        return SectionModel(
            key: KEY_NOTICE_DETAIL_SECTION,
            headerText: "peripheral_notice_section_header".localized,
            footerText: "peripheral_notice_section_footer".localized,
            rows: withRows ?? [])
    }
    
    static func createErrorCell() -> CellModel {
        return CellModel.infoCell(
            key: BasePeripheralData.errorKey,
            titleText: "peripheral_error_cell_title".localized,
            detailText: "peripheral_error_cell_code_prefix".localized,
            image: .init(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
            accessory: .disclosureIndicator)
    }
    
    static func createErrorDetailCell(code: Int) -> CellModel {
            return CellModel.infoDetailCell(
                key: BasePeripheralData.errorDetailKey,
                titleText: "peripheral_error_description_cell_title".localized + "\(code)",
                detailText: "peripheral_error_code_\(code)_description".localized,
                image: .init(systemName: "exclamationmark.circle.fill", withConfiguration: UIImage.largeScale)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                accessory: nil)
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

struct HiddenCells {
    var section = [SectionModel]()
    var cell = [CellModel]()
}

struct SectionModel: Equatable {
    var key: String?
    let headerText: String
    let footerText: String
    var rows: [CellModel]
    
    func getCellByKey(_ key: String) -> CellModel? {
        return rows.filter{ $0.cellKey == key }.first
    }

}

enum CellModel: Equatable {
    
    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        lhs.cellKey == rhs.cellKey
    }

    case colorCell(key: String, title: String, initialValue : UIColor, callback: (UIColor) -> Void)
    case pickerCell(key: String, title: String, initialValue: Any)
    case sliderCell(key: String, title: String, initialValue: Float, minValue: Float, maxValue: Float, leftIcon: UIImage?, rightIcon: UIImage?, showValue: Bool, callback: (Float) -> Void)
    case switchCell(key: String, title: String, initialValue: Bool, callback: (Bool) -> Void)
    case stepperCell(key: String, title: String, initialValue: Double, minValue: Double, maxValue: Double, callback: (Double) -> Void)
    case buttonCell(key: String, title: String, callback: () -> Void)
    case infoCell(key: String, titleText: String, detailText: String?, image: UIImage?, accessory: UITableViewCell.AccessoryType?)
    case infoDetailCell(key: String, titleText: String, detailText: String?, image: UIImage?, accessory: UITableViewCell.AccessoryType?)
    
    func getIndexPath(fromModel: TableViewModel) -> IndexPath? {
        return fromModel.getIndexPath(forRow: self)
    }
    
    var cellKey: String {
        switch self {
        case .colorCell(let key, _, _, _):         return key
        case .pickerCell(let key, _, _):        return key
        case .sliderCell(let key, _, _, _, _, _, _, _, _):  return key
        case .switchCell(let key, _, _, _):        return key
        case .stepperCell(let key, _, _, _, _, _): return key
        case .buttonCell(let key, _, _):           return key
        case .infoCell(let key, _, _, _, _):       return key
        case .infoDetailCell(let key, _, _, _, _): return key
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
        case .infoCell:    return InfoTableViewCell.reuseIdentifier
        case .infoDetailCell: return InfoDetailTableViewCell.reuseIdentifier
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
        case .infoCell:    return "InfoTableViewCell"
        case .infoDetailCell: return "InfoDetailTableViewCell"
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
        case .infoCell:    return InfoTableViewCell.self
        case .infoDetailCell: return InfoDetailTableViewCell.self
        }
    }
    
    func configure(cell: BaseTableViewCell, with data: PeripheralData) {
        switch self {
        case .sliderCell(key: let key, title: let title, initialValue: let initialValue, minValue: let minValue, maxValue: let maxValue, leftIcon: let leftIcon, rightIcon: let rightIcon, showValue: let showValue, callback: let callback):
            if let cell = cell as? SliderTableViewCell {
                cell.slider.minimumValue = minValue
                cell.slider.maximumValue = maxValue
                cell.slider.value        = Float(data.getValue(key: key) as? Int ?? Int(initialValue))
                cell.titleLabel.text     = title
                cell.valueLabel.isHidden = !showValue
                cell.valueLabel.text     = String(describing: Int(cell.slider.value))
                (leftIcon == nil) ? (cell.slider.minimumValueImage = nil) : (cell.slider.minimumValueImage = leftIcon)
                (rightIcon == nil) ? (cell.slider.maximumValueImage = nil) : (cell.slider.maximumValueImage = rightIcon)
                cell.callback = {
                    callback($0 as! Float)
                }
            }
        case .colorCell(key: let key, title: let title, initialValue: _, callback: let callback):
            if let cell = cell as? ColorTableViewCell {
                cell.configure(title: title, value: data.getValue(key: key))
                cell.callback = { callback($0 as! UIColor) }
            }
        case .pickerCell(key: let key, title: let title, initialValue: let initialValue):
            if let cell = cell as? PickerTableViewCell {
                cell.titleLabel.text = title
                if let dataValue = data.getValue(key: key) {
                    cell.valueLabel.text = String(describing: dataValue)
                } else {
                    cell.valueLabel.text = String(describing: initialValue)
                }
            }
        case .switchCell(key: let key, title: let title, initialValue: let initialValue, callback: let callback):
            if let cell = cell as? SwitchTableViewCell {
                cell.titleLabel.text = title
                cell.cellSwitch.isOn = data.getValue(key: key) as? Bool ?? initialValue
                cell.callback = { callback($0 as! Bool) }
            }
        case .stepperCell(key: let key, title: let title, initialValue: let initialValue, minValue: let minValue, maxValue: let maxValue, callback: let callback):
            if let cell = cell as? StepperTableViewCell {
                let dataValue = data.getValue(key: key) as? Int ?? Int(initialValue)
                cell.titleLabel.text = title
                cell.stepper.value = Double(dataValue)
                cell.valueLabel.text = String(describing: Int(cell.stepper.value))
                cell.stepper.minimumValue = minValue
                cell.stepper.maximumValue = maxValue
                cell.callback = { callback($0 as! Double) }
            }
        case .buttonCell(key:_, title: let title, callback: let callback):
            if let cell = cell as? ButtonTableViewCell {
                cell.button.setTitle(title, for: .normal)
                cell.callback = { _ in callback() }
            }
        case .infoCell(key: let key, titleText: let titleText, detailText: let detailText, image: let image, accessory: let accessory):
            if let cell = cell as? InfoTableViewCell {
                let value = data.getValue(key: key)
                if #available(iOS 14.0, *) {
                    var content = cell.defaultContentConfiguration()
                    content.image = image
                    content.text = titleText
                    content.secondaryText = String(describing: value ?? detailText ?? "")
                    cell.contentConfiguration = content
                } else {
                    cell.textLabel?.text =  titleText
                    cell.detailTextLabel?.text = String(describing: value ?? detailText ?? "")
                    cell.imageView?.image = image
                }
                cell.accessoryType = accessory ?? .none
            }
        case .infoDetailCell(key: _, titleText: let titleText, detailText: let detailText, image: let image, accessory: let accessory):
            if let cell = cell as? InfoDetailTableViewCell {
                cell.titleLabel.text = titleText
                cell.descriptionLabel.text = detailText
                cell.titleImage.image = image
                cell.accessoryType = accessory ?? .none
            }
        }
    }
    
}
