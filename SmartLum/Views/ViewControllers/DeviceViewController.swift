//
//  DeviceViewController.swift
//  SmartLum
//
//  Created by ELIX on 07.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

extension PeripheralPageViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
       return items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return items[section].rowCount
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
             return UITableViewCell(style: .default, reuseIdentifier: "cell")
             }
             return cell
         }()
        cell.textLabel?.text = "Hehe"
        return cell
    }
}

class PeripheralPageViewModel: NSObject {
    
    var items = [PeripheralViewModelItem]()
    var advData: AdvertisedData?
    var peripheral: TorcherePeripheral!
    var delegate: (ColorPeripheralDelegate & AnimationPeripheralDelegate)?
    
    
    init(advData: AdvertisedData, manager: CBCentralManager) {
        super.init()
        self.advData = advData
        peripheral = TorcherePeripheral.init(advData.peripheral, manager)

    }
    
    func find() {
        guard let peripheral = self.peripheral else {
            print("Shit")
            return
        }
        print("No shit")
        let data = PeripheralPageViewModel.parcePeripheralData(peripheral: peripheral)
        let profile = PeripheralView(peripheralInfo: data)
        if let name = profile?.peripheralName {
            print("Got name", name)
        }
        if let color = profile?.currentPrimaryColor {
            let item = PeripheralViewModelColorItem(color: color)
            items.append(item)
        }
        if let direction = profile?.currentAnimationDirection {
            let item = PeripheralViewModelAnimationDirectionItem(direction: direction)
            items.append(item)
        }
    }
    
    public static func parcePeripheralData(peripheral: BasePeripheral) -> PeripheralData {
        print("Parcing")
        var data = PeripheralData()
        print("Endpoints \(peripheral.endpoints)")
        for value in peripheral.endpoints.values {
            switch BluetoothEndpoint.getCharacteristic(characteristic: value) {
            case .primaryColor:
                print("Found primary color")
                data.currentPrimaryColor = UIColor.red
            case .animationMode:
                print("Found animation mode")
                data.currentAnimationMode = .rainbow
            case .animationDirection:
                print("Found animation direction")
                data.currentAnimationDirection = .fromBottom
            default:
                print("Unknown found")
            }
        }
        return data
    }
}

class PeripheralViewModelColorItem: PeripheralViewModelItem {
    var type: PeripheralViewModelItemType { return .color }
    var sectionTitle: String { return "Colors" }
    var color: UIColor
    init(color: UIColor) {
        self.color = color
    }
}

class PeripheralViewModelAnimationItem: PeripheralViewModelItem {
    var type: PeripheralViewModelItemType { return .animation}
    var sectionTitle: String { return "Animation"}
    var animation: PeripheralAnimations
    init(animation: PeripheralAnimations) {
        self.animation = animation
    }
}

class PeripheralViewModelAnimationDirectionItem: PeripheralViewModelItem {
    var type: PeripheralViewModelItemType { return .animationDirection }
    var sectionTitle: String { return "Direction" }
    var direction: PeripheralAnimationDirections
    init(direction: PeripheralAnimationDirections) {
        self.direction = direction
    }
}

protocol PeripheralViewModelItem {
    var type: PeripheralViewModelItemType { get }
    var rowCount: Int { get }
    var sectionTitle: String { get }
}

extension PeripheralViewModelItem {
    var rowCount: Int { return 1 }
}

enum PeripheralViewModelItemType {
    case color
    case random
    case animation
    case animationSpeed
    case animationDirection
    case animationStep
}

struct PeripheralData {
    var peripheralName:             String?
    var currentPrimaryColor:        UIColor?
    var currentSecondaryColor:      UIColor?
    var currentRandomColor:         Bool?
    var currentAnimationMode:       PeripheralAnimations?
    var currentAnimationDirection:  PeripheralAnimationDirections?
    var currentAnimationOnSpeed:    Int?
    var currentAnimationOffSpeed:   Int?
    var currentAnimationStep:       Int?
}

class PeripheralView {
    var peripheralName:             String?
    var currentPrimaryColor:        UIColor?
    var currentSecondaryColor:      UIColor?
    var currentRandomColor:         Bool?
    var currentAnimationMode:       PeripheralAnimations?
    var currentAnimationDirection:  PeripheralAnimationDirections?
    var currentAnimationOnSpeed:    Int?
    var currentAnimationOffSpeed:   Int?
    var currentAnimationStep:       Int?
    
    init?(peripheralInfo: PeripheralData) {
        self.peripheralName = peripheralInfo.peripheralName
        self.currentPrimaryColor = peripheralInfo.currentPrimaryColor
        self.currentSecondaryColor = peripheralInfo.currentSecondaryColor
        self.currentRandomColor = peripheralInfo.currentRandomColor
        self.currentAnimationMode = peripheralInfo.currentAnimationMode
        self.currentAnimationDirection = peripheralInfo.currentAnimationDirection
        self.currentAnimationOnSpeed = peripheralInfo.currentAnimationOnSpeed
        self.currentAnimationOffSpeed = peripheralInfo.currentAnimationOffSpeed
        self.currentAnimationStep = peripheralInfo.currentAnimationStep
    }
}

class DeviceViewController: UIViewController, AnimationPeripheralDelegate, ColorPeripheralDelegate {
    func peripheralDidConnect() {
        //
    }
    
    func peripheralDidDisconnect() {
        //
    }
    
    func peripheralIsReady() {
        //
    }
    
    func peripheralFirmwareVersion(_ version: Int) {
        //
    }
    
    func peripheralOnDFUMode() {
        //
    }
    
    
    func getAnimationMode(mode: Int) {
        //
    }
    
    func getAnimationOnSpeed(speed: Int) {
        //
    }
    
    func getAnimationOffSpeed(speed: Int) {
        //
    }
    
    func getAnimationDirection(direction: Int) {
        //
    }
    
    func getAnimationStep(step: Int) {
        //
    }
    
    func getPrimaryColor(_ color: UIColor) {
        //
    }
    
    func getSecondaryColor(_ color: UIColor) {
        //
    }
    
    func getRandomColor(_ state: Bool) {
        //
    }
    
    
    private var tableView: UITableView!
    public var peripheral: PeripheralPageViewModel!
    public var torcherePeripheral: TorcherePeripheral!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        self.torcherePeripheral = peripheral.peripheral
        torcherePeripheral.delegate = self
        peripheral.peripheral.connect()
        self.tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = false
        self.tableView.dataSource = peripheral
        self.view.addSubview(tableView)
        NSLayoutConstraint(item: tableView!,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.bottomMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView!,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.top,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView!,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView!,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.view,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        peripheral.find()
        tableView.reloadData()
    }

}
