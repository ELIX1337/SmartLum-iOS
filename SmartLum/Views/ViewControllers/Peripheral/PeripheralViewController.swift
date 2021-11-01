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
    func onCellSelected(cell: PeripheralCell)
}

extension PeripheralViewControllerProtocol {
    func onCellSelected(cell: PeripheralCell) { }
}

protocol PeripheralSetupViewControllerProtocol {
    func initComplete() -> Bool
}

func getPeripheralVC(peripheral: PeripheralProfile) -> PeripheralViewControllerProtocol {
    switch peripheral {
    case .FlClassic: return TorchereViewController()
    case .FlMini: return TorchereViewController()
    case .SlBase: return SlBaseViewController()
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
    case .FlClassic: return TorcherePeripheral.init(peripheral, manager)
    case .FlMini: return TorcherePeripheral.init(peripheral, manager)
    case .SlBase: return SlBasePeripheral.init(peripheral, manager)
    }
}

class PeripheralViewController: UIViewController {
    
    @objc var viewModel: PeripheralViewModel!
    var tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
    var alert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel?.peripheralName
        if (!viewModel.isConnected) {
            self.showConnectionAlert()
        }
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate   = self.viewModel
        self.tableView.tableViewType = .ready
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
        if let _ = viewModel.peripheralSettingsTableViewModel {
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
                        self.tableView.dataSource = self.viewModel
                        self.tableView.delegate   = self.viewModel
                        self.tableView.reloadData()
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
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.tableViewType = .setup
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
    
    @objc func confirmAction(_ sender:UIButton!) { }
    
    @objc func cancelAction(_ sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        initObserve?.invalidate()
        readyWriteObserve?.invalidate()
        if isBeingDismissed {
            dismiss(viewModel.isInitialized)
        }
        super.viewDidDisappear(animated)
    }
    
    private func addConfirmButton() {
        confirmButton.setTitle("button_confirm_peripheral_init".localized, for: UIControl.State.normal)
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        self.confirmButton.translatesAutoresizingMaskIntoConstraints = false
        self.confirmButton.layer.cornerRadius = 10.0
        self.confirmButton.backgroundColor = UIColor.SLWhite
        self.confirmButton.tintColor = UIColor.SLDarkBlue
        self.confirmButton.isEnabled = false
        self.view.addSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        let bot = confirmButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor)
        let left = confirmButton.leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = confirmButton.rightAnchor.constraint(equalTo: view.rightAnchor)
        bot.constant = -5
        bot.isActive = true
        left.constant = 10
        left.isActive = true
        right.constant = -10
        right.isActive = true
    }
    
    private func addCancelButton() {
        cancelButton.setTitle("button_cancel_peripheral_init".localized, for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        self.cancelButton.translatesAutoresizingMaskIntoConstraints = false
        self.cancelButton.layer.cornerRadius = 10.0
        self.cancelButton.backgroundColor = UIColor.SLWhite
        self.cancelButton.tintColor = UIColor.SLDarkBlue
        self.view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        let bot = cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        let left = cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor)
        let right = cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor)
        bot.constant = -15
        bot.isActive = true
        left.constant = 10
        left.isActive = true
        right.constant = -10
        right.isActive = true
    }
    
}

class PeripheralSettingsViewController: PeripheralViewController {
        
    override func viewDidLoad() {
        self.tableView = UITableView.init(frame: .zero, style: .insetGrouped)
        self.tableView.dataSource = viewModel
        self.tableView.delegate   = viewModel
        self.tableView.tableViewType = .settings
        addTableViewConstraints(tableView: self.tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "peripheral_settings_window_title".localized
    }
    
    override func viewDidDisappear(_ animated: Bool) { }
    
}
