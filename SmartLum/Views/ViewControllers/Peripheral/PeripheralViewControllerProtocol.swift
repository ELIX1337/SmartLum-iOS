//
//  PeripheralViewController.swift
//  SmartLum
//
//  Created by ELIX on 15.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewController: UIViewController {
    var viewModel: PeripheralViewModel!
    var tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel?.getPeripheralName()
        showAlert(title: "Connecting", message: "Connecting to \(String(describing: viewModel?.getPeripheralName()))", preferredStyle: .actionSheet)
        self.tableView.dataSource = self.viewModel
        self.tableView.delegate = self.viewModel
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.view.addSubview(tableView)
//        if #available(iOS 15.0, *) {
//            self.tableView.sectionHeaderTopPadding = 0
//        } 
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
        super.viewWillAppear(animated)
        if viewModel.peripheralIsConnected() {
            showAlert(title: "Connecting", message: "Connecting to \(viewModel.getPeripheralName())", preferredStyle: .actionSheet)
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            viewModel?.disconnect()
        }
    }
}

extension PeripheralViewController: BasePeripheralDelegate {
    
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

protocol PeripheralViewControllerProtocol {
    func viewModelInit(peripheral: BasePeripheral)
}

