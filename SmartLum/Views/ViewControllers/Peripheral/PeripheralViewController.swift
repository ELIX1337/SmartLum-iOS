//
//  PeripheralViewController.swift
//  SmartLum
//
//  Created by ELIX on 15.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol PeripheralViewControllerProtocol {
    func viewModelInit(peripheral: BasePeripheral)
    func onCellSelected(model: CellModel)
}

extension PeripheralViewControllerProtocol {
    func onCellSelected(model: CellModel) { }
}

protocol PeripheralSetupViewControllerProtocol {
    func initComplete() -> Bool
}

func getPeripheralVC(peripheral: PeripheralProfile) -> PeripheralViewControllerProtocol {
    switch peripheral {
    case .FlClassic:  return FlClassicViewController()
    case .FlMini:     return FlClassicViewController()
    case .SlBase:     return SlBaseViewController()
    case .SlStandart: return SlStandartViewController()
    }
}

func getPeripheralSetupVC(peripheral: BasePeripheral) -> PeripheralSetupViewController? {
    switch peripheral {
    case is SlBasePeripheral: return SlBaseSetupViewController()
    default: return nil
    }
}

func getPeripheralType(profile: PeripheralProfile, peripheral: CBPeripheral, manager: CBCentralManager) -> BasePeripheral {
    switch profile {
    case .FlClassic:  return FlClassicPeripheral.init(peripheral, manager)
    case .FlMini:     return FlClassicPeripheral.init(peripheral, manager)
    case .SlBase:     return SlBasePeripheral.init(peripheral, manager)
    case .SlStandart: return SlStandartPeripheral.init(peripheral, manager)
    }
}

class PeripheralViewController: UIViewController {
    
    @objc var viewModel: PeripheralViewModel!
    var tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
    var alert: UIAlertController?
    var pickerDataSource: TablePickerViewDataSource<PeripheralDataElement>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel?.peripheralName
        if (!viewModel.isConnected) {
            self.showConnectionAlert()
        }
        addTableViewConstraints(tableView: self.tableView)
    }
    
    func addTableViewConstraints(tableView: UITableView) {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.cellLayoutMarginsFollowReadableWidth      = false
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .ready)
        if viewModel.peripheralSettingsAvailable {
            let btn = UIBarButtonItem.init(image: UIImage.init(systemName: "gearshape"), style: .done, target: self, action: #selector(self.openPeripheralSettings))
            self.navigationItem.rightBarButtonItem = btn
        }
    }
    
    @objc func openPeripheralSettings() {
        print("Settings")
        let vc = PeripheralSettingsViewController()
        vc.viewModel = self.viewModel
        navigationController?.pushViewController(vc, animated: true)
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (self.isMovingFromParent) {
            viewModel?.disconnect()
        }
    }
    
    func initPickerDataSource<T: PeripheralDataElement>(with elements: [T], callback: @escaping (T) -> Void) {
        self.pickerDataSource = TablePickerViewDataSource<PeripheralDataElement>(withItems: elements, withSelection: PeripheralAnimations.rainbow, withRowTitle: { $0.name.localized })
        {
            callback($0 as! T)
        }
    }
    
    func pushPicker<T: PeripheralDataElement>(_ dataArray: [T], _ callback: @escaping (T) -> Void) {
        let vc = TablePickerViewController()
        initPickerDataSource(with: dataArray, callback: callback)
        vc.delegate = pickerDataSource
        vc.dataSource = pickerDataSource
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func pushColorPicker(_ sender: CellModel, initColor: UIColor, onColorChange: @escaping (_ color: UIColor, _ sender: Any) -> Void) {
        let vc = ColorPickerViewController()
        vc.configure(initColor: initColor, colorIndicator: nil, sender: sender, onColorChange: onColorChange)
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

}

extension PeripheralViewController {
    
    public func showConnectionAlert() {
        self.alert = UIAlertController(title: "Connecting to \(self.viewModel.peripheralName)", message: "", preferredStyle: .actionSheet)
        self.present(alert!, animated: false, completion: nil)
    }
    
    public func hideConnectionAlert() {
        self.alert?.dismiss(animated: true, completion: nil)
    }
    
    public func showResetAlert() {
        let alert = UIAlertController(
            title: "peripheral_reset_alert_title".localized,
            message: "peripheral_reset_alert_text".localized,
            preferredStyle: .alert)
        alert.addAction(.init(
            title: "peripheral_reset_alert_confirm_button".localized,
            style: .destructive,
            handler: { _ in
                self.viewModel.setFactorySettings()
                self.navigationController?.popToRootViewController(animated: true)
            }))
        alert.addAction(.init(
            title: "peripheral_reset_alert_cancel_button".localized,
            style: .cancel,
            handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    public func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension PeripheralViewController: PeripheralViewModelDelegate {
    
    func peripheralInitState(isInitialized: Bool) {
        print("is init \(isInitialized)")
        viewModel.dataModel.setValue(key: BasePeripheralData.initStateKey, value: isInitialized)
        viewModel.isInitialized = isInitialized
        if (!isInitialized) {
            hideConnectionAlert()
            if let setupViewController = getPeripheralSetupVC(peripheral: viewModel.basePeripheral) {
                setupViewController.viewModel = viewModel
                setupViewController.dismiss = { gotInit in
                    if !gotInit {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.navigationController?.visibleViewController?.showErrorAlert(title: "Disconnected", message: "Device setup failed")
                    } else {
                        self.viewModel.resetTableView(tableView: self.tableView, delegate: self, tableViewType: .ready)
                    }
                }
                navigationController?.present(setupViewController, animated: true, completion: nil)
                tableView.reloadData()
            }
        }
    }
    
    func peripheralDidConnect() {
        hideConnectionAlert()
    }
    
    func peripheralDidDisconnect(reason: Error?) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        print("Disconnect reason - \(String(describing: reason?.localizedDescription))")
    }
    
    func peripheralIsReady() {
    }
    
    func peripheralOnDFUMode() {
        print("PERIPHERAL IS ON DFU MODE")
    }
}

class PeripheralSetupViewController: PeripheralViewController {
    
    let confirmButton = UIButton(type: UIButton.ButtonType.roundedRect) as UIButton
    let cancelButton = UIButton(type: UIButton.ButtonType.roundedRect) as UIButton
    var showConfirmButton: Bool = true
    var dismiss: (_ initState: Bool) -> Void = { initState in }
    var readyWriteObserve: NSKeyValueObservation?
    var initObserve: NSKeyValueObservation?
    
    override func viewDidLoad() {
        tableView = UITableView.init(frame: .zero, style: .insetGrouped)
        tableView.tableViewType = .setup
        addTableViewConstraints(tableView: tableView)
        addCancelButton()
        if (showConfirmButton) {
            addConfirmButton()
            readyWriteObserve = observe(\.viewModel.readyToWriteInitData, options: .new) { vc, newValue in
                self.confirmButton.isEnabled = newValue.newValue ?? false
            }
        }
        initObserve = observe(\.viewModel?.isInitialized, options: .new) { vc, newValue in
            if (newValue.newValue == true) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .setup)
    }

    override func viewDidDisappear(_ animated: Bool) {
        initObserve?.invalidate()
        readyWriteObserve?.invalidate()
        if isBeingDismissed {
            dismiss(viewModel.isInitialized)
        }
        super.viewDidDisappear(animated)
    }
    
    override func addTableViewConstraints(tableView: UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    }
    
    private func addConfirmButton() {
        confirmButton.setTitle("button_confirm_peripheral_init".localized, for: UIControl.State.normal)
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 10.0
        confirmButton.backgroundColor = UIColor.SLWhite
        confirmButton.tintColor = UIColor.SLDarkBlue
        confirmButton.isEnabled = false
        view.addSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -5).isActive = true
        confirmButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        confirmButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    private func addCancelButton() {
        cancelButton.setTitle("button_cancel_peripheral_init".localized, for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.cornerRadius = 10.0
        cancelButton.backgroundColor = UIColor.SLWhite
        cancelButton.tintColor = UIColor.SLDarkBlue
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    @objc func confirmAction(_ sender:UIButton!) { }
    
    @objc func cancelAction(_ sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

class PeripheralSettingsViewController: PeripheralViewController {
            
    override func viewWillAppear(_ animated: Bool) {
        self.title = "peripheral_settings_window_title".localized
        self.tableView = UITableView.init(frame: .zero, style: .insetGrouped)
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .settings)
        addTableViewConstraints(tableView: self.tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // Do not remove!
    }
    
}
