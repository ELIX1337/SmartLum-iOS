//
//  ScannerTableViewController.swift
//  SmartLum
//
//  Created by Tim on 24/10/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

class ScannerTableViewController: UITableViewController, CBCentralManagerDelegate {
    
    // MARK: - Outlets and Actions
    
    @IBOutlet weak var emptyPeripheralsView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var emptyViewHeader: UILabel!
    
    // MARK: - Properties
    
    private var centralManager: CBCentralManager!
    private var discoveredPeripherals = [AdvertisedData]()
    
    // MARK: - UIViewController
    @IBAction func pushAbout(_ sender: Any) {
        let vc = AboutViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        discoveredPeripherals.removeAll()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        centralManager.delegate = self
        if centralManager.state == .poweredOn {
            activityIndicator.startAnimating()
            centralManager.scanForPeripherals(withServices: Array(UUIDs.advServices),
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        //NetworkPermissionTrigger.triggerPermission()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hideEmptyPeripheralsView()
    }
    
    @objc func refresh(sender:AnyObject) {
        discoveredPeripherals.removeAll()
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = 0
        })
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = 0.5
        })
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0.2, animations: {
            self.activityIndicator.alpha = 1
        })
    }
    
    // MARK: - UITableViewDelegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if discoveredPeripherals.count > 0 {
            hideEmptyPeripheralsView()
        } else {
            showEmptyPeripheralsView()
        }
        return discoveredPeripherals.count > 0 ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "scanner_section_header".localized
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discoveredPeripherals.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aCell = tableView.dequeueReusableCell(withIdentifier: ScannerTableViewCell.reuseIdentifier, for: indexPath) as! ScannerTableViewCell
        let peripheral = discoveredPeripherals[indexPath.row]
        aCell.setupView(withPeripheral: peripheral)
        return aCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        centralManager.stopScan()
        activityIndicator.stopAnimating()
        tableView.deselectRow(at: indexPath, animated: true)
        pushViewController(advertisedData: discoveredPeripherals[indexPath.row])
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let newPeripheral = AdvertisedData(withPeripheral: peripheral, advertisementData: advertisementData, andRSSI: RSSI, using: centralManager)
        
        if !discoveredPeripherals.contains(newPeripheral) {
            discoveredPeripherals.append(newPeripheral)
            tableView.beginUpdates()
            if discoveredPeripherals.count == 1 {
                tableView.insertSections(IndexSet(integer: 0), with: .fade)
            }
            tableView.insertRows(at: [IndexPath(row: discoveredPeripherals.count - 1, section: 0)], with: .fade)
            tableView.endUpdates()
        } else {
            if let index = discoveredPeripherals.firstIndex(of: newPeripheral) {
                if let aCell = tableView.cellForRow(at: [0, index]) as? ScannerTableViewCell {
                    aCell.peripheralUpdatedAdvertisementData(newPeripheral)
                }
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Central is not powered on")
        } else {
            activityIndicator.startAnimating()
            centralManager.scanForPeripherals(withServices: Array(UUIDs.advServices),
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    // MARK: - Implementation
    
    private func showEmptyPeripheralsView() {
        if !view.subviews.contains(emptyPeripheralsView) {
            view.addSubview(emptyPeripheralsView)
            emptyPeripheralsView.alpha = 0
            emptyPeripheralsView.frame = CGRect(x: 0,
                                                y: 0,
                                                width: view.frame.width,
                                                height: view.frame.height/2)
            view.bringSubviewToFront(emptyPeripheralsView)
            UIView.animate(withDuration: 0.5, animations: {
                self.emptyPeripheralsView.alpha = 1
            })
        }
    }
    
    private func hideEmptyPeripheralsView() {
        if view.subviews.contains(emptyPeripheralsView) {
            UIView.animate(withDuration: 0.5, animations: {
                self.emptyPeripheralsView.alpha = 0
            }, completion: { completed in
                self.emptyPeripheralsView.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Segue and navigation
    
    private func pushViewController(advertisedData: AdvertisedData) {
        if let type = advertisedData.peripheralType {
            let vc = PeripheralProfile.getPeripheralVC(peripheral: type)
            let peripheral = type.getPeripheralType(peripheral: advertisedData.peripheral, manager: centralManager)
            peripheral.deviceType = type
            vc.viewModelInit(peripheral: peripheral)
            navigationController?.pushViewController(vc as! UIViewController, animated: true)
        }
    }

}
