//
//  DeviceViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class TorchereViewController: UIViewController, BasePeripheralDelegate {
    
    private var viewModel: TorchereViewModel!
    private var pickerDataSource: TablePickerViewDataSource<PeripheralDataElement>?
    private var tableView = UITableView.init(frame: .zero, style: .grouped)
    
    func configure(withPeripheral: BasePeripheral) {
        self.viewModel = TorchereViewModel(self.tableView,
                                           withPeripheral,
                                           self,
                                           { self.onCellSelected($0) })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel.getPeripheralName()
        showAlert(title: "Connecting", message: "Connecting to \(viewModel.getPeripheralName())", preferredStyle: .actionSheet)
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self.viewModel
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.view.addSubview(tableView)
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.bottomMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.top,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if viewModel.peripheralIsConnected() {
            showAlert(title: "Connecting", message: "Connecting to \(viewModel.getPeripheralName())", preferredStyle: .actionSheet)
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.popToRootViewController(animated: true)
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            viewModel.disconnect()
        }
    }
    
    func initPickerDataSource<T: PeripheralDataElement>(with elements: [T]) {
        self.pickerDataSource = TablePickerViewDataSource<PeripheralDataElement>(withItems: elements, withSelection: PeripheralAnimations.rainbow, withRowTitle: { $0.name.localized })
        {
            switch $0 {
            case let selection as PeripheralAnimations:
                self.viewModel?.writeAnimationMode(mode: selection)
                break
            case let selection as PeripheralAnimationDirections:
                self.viewModel?.writeAnimationDirection(direction: selection)
                break
            default:
                print("Unknown selection - ", $0)
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
        let vc = ColorPickerViewController()
        vc.configure(initColor: (sender.cellValue(from: viewModel!.dataModel)) as? UIColor,
                     colorIndicator: nil,
                     sender: sender,
                     onColorChange: { color, sender in
                        switch sender as? PeripheralRow {
                        case .primaryColor:
                            self.viewModel?.writePrimaryColor(color: color)
                            break
                        case .secondaryColor:
                            self.viewModel?.writeSecondaryColor(color: color)
                            break
                        default:
                            print("Unknown sender")
                        }
                     })
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - BasePeripheralDelegate
    
    func peripheralDidConnect() {
    }
    
    func peripheralDidDisconnect() {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func peripheralIsReady() {
        hideAlert()
    }
    
    func peripheralFirmwareVersion(_ version: Int) {
        print("PERIPHERAL FIRMWARE VERSION - ", version)
    }
    
    func peripheralOnDFUMode() {
        print("PERIPHERAL IS ON DFU MODE")
    }
    
}

extension UIViewController {
    
    public func showAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        self.present(alert, animated: false, completion: nil)
    }
    
    public func hideAlert() {
        self.dismiss(animated: true, completion: nil)
    }
}
