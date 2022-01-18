//
//  SlBaseViewController.swift
//  SmartLum
//
//  Created by ELIX on 14.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Конкретный класс реализующий экран устройства SL-Base
class SlBaseViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    /// Инициализируем ViewModel
    /// Как можно заметить, нам приходится явно указывать тип ViewModel в каждом конкретном ViewController'e
    /// Это тупо и должно быть автоматизировано, либо ViewModel должна быть одна на всех
    func viewModelInit(peripheral: BasePeripheral) {
        viewModel = SlBaseViewModel(tableView, peripheral, self, onCellSelected(model:))
    }
    
    /// Обрабатываем нажатия по ячейкам tableView (только необходимым)
    /// По идее такие ячейки как Error и ResetToFactory должны обрабатываться по дефолту в родительском классе
    func onCellSelected(model: CellModel) {
        switch model.cellKey {
        case BasePeripheralData.errorKey:
            openPeripheralSettings()
            break
        case BasePeripheralData.factoryResetKey:
            showResetAlert()
            break
        default: break
        }
    }
    
}

class SlBaseSetupViewController: PeripheralSetupViewController {
    
    /// Задаем действие на кнопку "Подтвердить".
    /// В данном случае мы пишем дистанцию срабатывания датчиков.
    /// На самом деле тоже можно все автоматизировать чтобы не писать реализацию в каждом классе-наследнике.
    override func confirmAction(_ sender: UIButton!) {
        confirmButton.isEnabled = !(viewModel as! SlBaseViewModel).writeInitDistance()
    }
}
