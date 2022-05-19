//
//  CellModel.swift
//  SmartLum
//
//  Created by ELIX on 14.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import UIKit

enum CellModel: Equatable {
    
    // Приводим в соответсвие протоколу Equatable
    static func == (lhs: CellModel, rhs: CellModel) -> Bool {
        lhs.cellKey == rhs.cellKey
    }

    // Типы ячеек
    // Callback - это данные возвращаемые с ячейки, например изменение значения слайдера идет в Callback, который обрабатывается во ViewModel
    case colorCell(key: String, title: String, initialValue : UIColor, callback: (UIColor) -> Void)
    case pickerCell(key: String, title: String, initialValue: Any)
    case sliderCell(key: String, title: String, initialValue: Float, minValue: Float, maxValue: Float, leftIcon: UIImage?, rightIcon: UIImage?, showValue: Bool, callback: (Float) -> Void)
    case switchCell(key: String, title: String, initialValue: Bool, callback: (Bool) -> Void)
    case stepperCell(key: String, title: String, initialValue: Double, minValue: Double, maxValue: Double, callback: (Double) -> Void)
    case buttonCell(key: String, title: String, callback: () -> Void)
    case infoCell(key: String, titleText: String, detailText: String?, image: UIImage?, accessory: UITableViewCell.AccessoryType?)
    case infoDetailCell(key: String, titleText: String, detailText: String?, image: UIImage?, accessory: UITableViewCell.AccessoryType?)
    
    // Возвращает IndexPath ячейки из модели таблицы (вроде бы нигде не используется, но добавил как возможность)
    func getIndexPath(fromModel: TableViewModel) -> IndexPath? {
        return fromModel.getIndexPath(forRow: self)
    }
    
    // Ключ ячейки. Каждая ячейка имеет свой ключ (id) по которому она идентифицируется
    var cellKey: String {
        switch self {
        case .colorCell(let key, _, _, _):         return key
        case .pickerCell(let key, _, _):           return key
        case .sliderCell(let key, _, _, _, _, _, _, _, _):  return key
        case .switchCell(let key, _, _, _):        return key
        case .stepperCell(let key, _, _, _, _, _): return key
        case .buttonCell(let key, _, _):           return key
        case .infoCell(let key, _, _, _, _):       return key
        case .infoDetailCell(let key, _, _, _, _): return key
        }
    }
    
    // Значение в ячейке (вроде нигде не используется, но по хорошему и не должно)
    func cellValue(from model: PeripheralDataStorage) -> Any? {
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
    
    // Класс ячейки. Нигде пока не пригодилось
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
    
    // Функция, которая получает ячейку и конфигурирует ее в соответсвии с типой этой ячейки
    // data - это ключ-значение массив со всеми данными, ячейка получает необходимое ей значение по ее ключу,
    // т.е. ключ ячейки (key) соответствует определенному ключу в этом массиве
    func configure(cell: BaseTableViewCell, with data: PeripheralDataStorage) {
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
                // Govnocode
                // Если данные статичные, то используй detailText, иначе будет брать через ключ
                if #available(iOS 14.0, *) {
                    var content = cell.defaultContentConfiguration()
                    content.image = image
                    content.text = titleText
                    content.secondaryText = String(describing: data.getValue(key: key) ?? detailText)
                    cell.contentConfiguration = content
                } else {
                    cell.textLabel?.text =  titleText
                    cell.detailTextLabel?.text = String(describing: data.getValue(key: key) ?? detailText)
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
