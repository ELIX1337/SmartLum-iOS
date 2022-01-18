//
//  FirmwareUpdateViewController.swift
//  SmartLum
//
//  Created by Tim on 20.02.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth
import iOSDFULibrary

/// ВНИМАНИЕ: Этот код использовался при тестировании DFU. В продакшене он не применяется.
/// Здесь происходит обновление прошивки устройства по Bluetooth.
/// Подробную информацию лучше посмотреть у Nordic Semiconductor в их примерах.
/// Обновляет прошивку только у микроконтроллеров Nordic.
/// Работает четко и круто.
class FirmwareUpdateViewController: UIViewController,
                                    CBCentralManagerDelegate,
                                    LoggerDelegate,
                                    DFUServiceDelegate,
                                    DFUProgressDelegate {
    
    private var centralManager: CBCentralManager!
    private var DFUController: DFUServiceController?
    private var peripheral: CBPeripheral?
    private var firmwareURL: URL?
    var peripheralUUID: CBUUID?
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var statusLabel: UILabel!
    @IBOutlet private weak var progressLabel: UILabel!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var progressIndicator:UIProgressView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - DFU service identifier
    private let DFUServiceUUID = [CBUUID(string:"0xFE59")]
    
    override func viewDidAppear(_ animated: Bool) {
        centralManager.delegate = self
        //startScan()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager()
        if let uuid = peripheralUUID {
            checkForUpdate(forDeviceWith: uuid)
        }
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.title = "Device firmware update"
    }
    
    @IBAction func onCancelTapped(_ sender: UIButton) {
        centralManager.stopScan()
        _ = DFUController?.abort()
        self.dismiss(animated: true, completion: nil)
    }
    
    private func startScan() {
        if centralManager.state != .poweredOn {
            print("Bluetooth is not powered on")
            statusLabel.text = "Bluetooth is not powered on"
        } else {
            centralManager.scanForPeripherals(withServices: DFUServiceUUID,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            print("Scanning for DFU")
        }
    }
    
    // MARK: - CBCentralManagerDelegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            print("Bluetooth is not powered on")
            statusLabel.text = "Bluetooth is not powered on"
        } else {
            centralManager.scanForPeripherals(withServices: DFUServiceUUID,
                                              options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        centralManager.stopScan()
        self.peripheral = peripheral
        if let url = firmwareURL {
            startUpdating(firmware: url)
        }
    }
    
    // MARK:- Getting firmware file
    
    private func checkForUpdate(forDeviceWith uuid: CBUUID) {
        statusLabel.text = "Checking for update..."
        let firmwareDownloader = FirmwareDownloader()
        firmwareDownloader.checkDeviceForUpdates(with: uuid.uuidString, withCompletion: { device, error in
            if let device = device {
                if let firmwareURL = URL(string: firmwareDownloader.baseURL + device.firmwareURL!) {
                    firmwareDownloader.downloadFirmware(from: firmwareURL, withCompletion: { url, error in
                        if let url = url {
                            #warning("TODO: set peripheral to DFU mode")
                            DispatchQueue.main.async {
                                self.statusLabel.text = "Preparing the device for the update..."
                            }
                            self.firmwareURL = url
                            self.startScan()
                        } else {
                            #warning("TODO: dismiss with message")
                            DispatchQueue.main.async {
                                self.statusLabel.text = "You are using newest firmware"
                            }
                            print(error ?? "Some error")
                        }
                    })
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.statusLabel.text = error.detail
                    self.hideView(view: [self.activityIndicator], isHidden: true)
                }
            }
        })
    }
    
    private func startUpdating(firmware url: URL) {
        statusLabel.text = "Preparing firmware file"
        guard let selectedFirmware = DFUFirmware(urlToZipFile: url) else {
            print("Cannot create firmware from selected file: \(url)")
            return
        }
        let initiator = DFUServiceInitiator().with(firmware: selectedFirmware)
        initiator.logger = self
        initiator.delegate = self
        initiator.progressDelegate = self
        if let peripheral = self.peripheral {
            DFUController = initiator.start(target: peripheral)
            statusLabel.text = "Updating firmware..."
            hideView(view: [progressLabel, progressIndicator, speedLabel], isHidden: false)
            hideView(view: [activityIndicator], isHidden: true)
        }
    }
    
    private func hideView(view: [UIView], isHidden: Bool) {
        for v in view {
            UIView.transition(with: v, duration: 0.5, options: .transitionCrossDissolve, animations: {
                v.isHidden = isHidden
            })
        }
    }
        
    // MARK: - DFU Log
    
    func logWith(_ level: LogLevel, message: String) {
        print("DFU log: \(message)")
    }
    
    func dfuStateDidChange(to state: DFUState) {
        print("DFU log: state - \(state)")
        switch state {
        case DFUState.aborted:
            self.dismiss(animated: true, completion: nil)
            break
        case DFUState.completed:
            do {
                try FileManager.default.removeItem(at: firmwareURL!)
            } catch {
                print(error)
            }
            hideView(view: [progressLabel, progressIndicator, speedLabel], isHidden: true)
            statusLabel.text = "Device firmware successfully updated"
            //self.dismiss(animated: true, completion: nil)
            break
        default:
            print("DFU log: unknown state - \(state)")
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("DFU log: error - \(message)")
    }
    
    // MARK: - DFU Progress
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int, currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        progressIndicator.setProgress(Float(progress) / 100, animated: true)
        progressLabel.text = String("\(part)/\(totalParts): \(progress)%")
        speedLabel.text = String("\(round(currentSpeedBytesPerSecond / 1024)) kB/s")
    }

}
