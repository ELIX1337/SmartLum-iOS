//
//  SlProViewController.swift
//  SmartLum
//
//  Created by ELIX on 09.11.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Конкретный класс реализующий экран устройств SL-Pro и SL-Standart.
/// По факту тупо добавляет обработку на нажатия по ячейкам таблицы
class SlProStandartViewController: PeripheralViewController {
        
    /// Обрабатываем нажатия по ячейкам tableView (только необходимым)
    override func onCellSelected(model: CellModel) {
        super.onCellSelected(model: model)
        if let mViewModel = self.viewModel as? SlProStandartViewModel {
            switch model {
            case mViewModel.primaryColorCell:
                pushColorPicker(model, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(SlProStandartAnimations.allCases, title: "peripheral_animation_mode_cell_title".localized) { selection in
                    mViewModel.writeAnimationMode(mode: selection)
                }
                break
            case mViewModel.stairsWorkModeCell:
                pushPicker(PeripheralStairsWorkMode.allCases, title: "peripheral_sl_pro_stairs_work_mode_cell_title".localized) { mode in
                    mViewModel.writeStairsWorkMode(mode: mode)
                }
                break
            case mViewModel.ledAdaptiveCell:
                pushPicker(PeripheralLedAdaptiveMode.allCases, title: "peripheral_sl_pro_adaptive_brightness_cell_title".localized) { mode in
                    mViewModel.writeLedAdaptiveBrightnessMode(mode: mode)
                }
                break
            default:
                return
            }
        }
    }
    
}
