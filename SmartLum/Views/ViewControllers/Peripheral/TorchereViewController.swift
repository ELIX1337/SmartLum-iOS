//
//  DeviceViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class TorchereViewController: PeripheralViewController, PeripheralViewControllerProtocol {
    
    private var pickerDataSource: TablePickerViewDataSource<PeripheralDataElement>?
    
    func viewModelInit(peripheral: BasePeripheral) {
        self.viewModel = TorchereViewModel(self.tableView,
                                           peripheral,
                                           self,
                                           { self.onCellSelected($0) })
    }
    
    func initPickerDataSource<T: PeripheralDataElement>(with elements: [T]) {
        self.pickerDataSource = TablePickerViewDataSource<PeripheralDataElement>(withItems: elements, withSelection: PeripheralAnimations.rainbow, withRowTitle: { $0.name.localized })
        {
            if let viewModel = self.viewModel as? TorchereViewModel {
                switch $0 {
                case let selection as PeripheralAnimations:
                    viewModel.writeAnimationMode(mode: selection)
                    break
                case let selection as PeripheralAnimationDirections:
                    viewModel.writeAnimationDirection(direction: selection)
                    break
                default:
                    print("Unknown selection - ", $0)
                }
            }
        }
    }
    
    private func pushPicker<T: PeripheralDataElement>(_ dataArray: [T]) {
        let vc = TablePickerViewController()
        initPickerDataSource(with: dataArray)
        vc.delegate = pickerDataSource
        vc.dataSource = pickerDataSource
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func onCellSelected(_ selection: PeripheralRow) {
        switch selection {
        case .primaryColor,
                .secondaryColor:
            pushColorPicker(selection)
            break
        case .animationMode:
            self.pushPicker(PeripheralAnimations.allCases)
            break
        case .animationDirection:
            self.pushPicker(PeripheralAnimationDirections.allCases)
            break
        case .animationStep:
            tableView.reloadData()
        default: print("default")
        }
    }
    
    private func pushColorPicker(_ sender: PeripheralRow) {
        if let viewModel = self.viewModel as? TorchereViewModel {
            let vc = ColorPickerViewController()
            vc.configure(initColor: (sender.cellValue(from: viewModel.dataModel)) as? UIColor,
                         colorIndicator: nil,
                         sender: sender,
                         onColorChange: { color, sender in
                switch sender as? PeripheralRow {
                case .primaryColor:
                    viewModel.writePrimaryColor(color: color)
                    break
                case .secondaryColor:
                    viewModel.writeSecondaryColor(color: color)
                    break
                default:
                    print("Unknown sender")
                }
            })
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
}
