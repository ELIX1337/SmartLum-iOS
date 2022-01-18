//
//  FlClassicViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Конкретный класс реализующий экран устройства FL-Classic
class FlClassicViewController: PeripheralViewController, PeripheralViewControllerProtocol {
        
    /// Инициализируем ViewModel
    /// Как можно заметить, нам приходится явно указывать тип ViewModel в каждом конкретном ViewController'e
    /// Это тупо и должно быть автоматизировано, либо ViewModel должна быть одна на всех
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = FlClassicViewModel(tableView, peripheral, self) {
            self.onCellSelected(cell: $0)
        }
    }
    
    /// Обрабатываем нажатия по ячейкам tableView (только необходимым)
    func onCellSelected(cell: CellModel) {
        if let mViewModel = viewModel as? FlClassicViewModel {
            switch cell {
            case mViewModel.primaryColorCell:
                pushColorPicker(cell, initColor: mViewModel.primaryColor) { color, _ in
                    mViewModel.writePrimaryColor(color: color)
                }
                return
            case mViewModel.secondaryColorCell:
                pushColorPicker(cell, initColor: mViewModel.secondaryColor) { color, _ in
                    mViewModel.writeSecondaryColor(color: color)
                }
                break
            case mViewModel.animationModeCell:
                pushPicker(FlClassicAnimations.allCases) {
                    mViewModel.writeAnimationMode(mode: $0)
                }
                break
            case mViewModel.animationDirectionCell:
                pushPicker(PeripheralAnimationDirections.allCases) {
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
