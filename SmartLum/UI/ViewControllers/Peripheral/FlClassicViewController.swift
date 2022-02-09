//
//  FlClassicViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Конкретный класс реализующий экран устройства FL-Classic.
/// По факту тупо добавляет обработку на нажатия по ячейкам таблицы
class FlClassicViewController: PeripheralViewController {
        
    /// Обрабатываем нажатия по ячейкам tableView (только необходимым)
    override func onCellSelected(model: CellModel) {
        super.onCellSelected(model: model)
        if let mViewModel = viewModel as? FlClassicViewModel {
            switch model {
            case mViewModel.primaryColorCell:
                pushColorPicker(model, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color: color)
                }
                return
            case mViewModel.secondaryColorCell:
                pushColorPicker(model, initColor: mViewModel.secondaryColor) { color, _ in
                    mViewModel.writeSecondaryColor(color: color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(FlClassicAnimations.allCases, title: "peripheral_animation_mode_cell_title".localized) {
                    mViewModel.writeAnimationMode(mode: $0)
                }
                break
            case mViewModel.animationDirectionCell:
                pushPicker(PeripheralAnimationDirections.allCases, title: "peripheral_animation_direction_cell_title".localized) {
                    mViewModel.writeAnimationDirection(direction: $0)
                }
                break
            default:
                return
            }
        }
    }
    
}

// У устройства нет настройки и поэтому тут только один экран.
