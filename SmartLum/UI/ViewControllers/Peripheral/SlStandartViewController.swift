//
//  SlStandartViewController.swift
//  SmartLum
//
//  Created by ELIX on 10.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Конкретный класс реализующий экран устройства SL-Standart
/// По идее не имеет совершенно никаких отличий от устройства SL-PRO и можно использовать один ViewController на оба устройства
/// Отличия только в инициализации ViewModel
class SlStandartViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    /// Инициализируем ViewModel
    /// Как можно заметить, нам приходится явно указывать тип ViewModel в каждом конкретном ViewController'e
    /// Это тупо и должно быть автоматизировано, либо ViewModel должна быть одна на всех
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = SlStandartViewModel(self.tableView, peripheral, self) {
            self.onCellSelected(model:$0)
            guard let vm = self.viewModel as? SlProViewModel else { return }
            switch $0.cellKey {
            case StairsControllerData.stairsWorkModeKey:
                self.pushPicker(PeripheralStairsWorkMode.allCases) { mode in
                    vm.writeStairsWorkMode(mode: mode)
                }
                break
            case StairsControllerData.ledAdaptiveModeKey:
                self.pushPicker(PeripheralLedAdaptiveMode.allCases) { mode in
                    vm.writeLedAdaptiveBrightnessMode(mode: mode)
                }
                break
            case BasePeripheralData.factoryResetKey:
                self.showResetAlert()
                break
            default:
                break
            }
            
        }
    }
        
    /// Обрабатываем нажатия по ячейкам tableView (только необходимым)
    /// По идее такие ячейки как Error и ResetToFactory должны обрабатываться по дефолту в родительском классе
    func onCellSelected(model: CellModel) {
        if let mViewModel = self.viewModel as? SlStandartViewModel {
            switch model {
            case mViewModel.animationModeCell:
                pushPicker(SlProAnimations.allCases) { selection in
                    mViewModel.writeAnimationMode(mode: selection)
                }
                break
            default:
                return
            }
        }
    }
    
}

class SlStandartSetupViewController: PeripheralSetupViewController {
    
    /// Задаем действие на кнопку "Подтвердить".
    /// В данном случае мы пишем дистанцию срабатывания датчиков.
    /// На самом деле тоже можно все автоматизировать чтобы не писать реализацию в каждом классе-наследнике.
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}

