//
//  PeripheralTableViewCell.swift
//  SmartLum
//
//  Created by Tim on 01/11/2020.
//  Copyright © 2020 SmartLum. All rights reserved.
//

import UIKit

class ScannerTableViewCell: UITableViewCell {
    
    //MARK: - Outlets and Actions
    
    @IBOutlet weak var peripheralName: UILabel!
    @IBOutlet weak var peripheralRSSIIcon: UIImageView!
    
    // MARK: - Properties
    
    static let reuseIdentifier = "PeripheralCell"
    
    private var lastUpdateTimestamp = Date()
    
    // MARK: - Implementation
    
    public func setupView(withPeripheral aPeripheral: AdvertisedData) {
        peripheralName.text = aPeripheral.advertisedName

        if aPeripheral.RSSI.decimalValue < -60 {
            peripheralRSSIIcon.image = #imageLiteral(resourceName: "rssi_2")
        } else if aPeripheral.RSSI.decimalValue < -50 {
            peripheralRSSIIcon.image = #imageLiteral(resourceName: "rssi_3")
        } else if aPeripheral.RSSI.decimalValue < -30 {
            peripheralRSSIIcon.image = #imageLiteral(resourceName: "rssi_4")
        } else {
            peripheralRSSIIcon.image = #imageLiteral(resourceName: "rssi_1")
        }
    }
    
    public func peripheralUpdatedAdvertisementData(_ aPeripheral: AdvertisedData) {
        if Date().timeIntervalSince(lastUpdateTimestamp) > 1.0 {
            lastUpdateTimestamp = Date()
            setupView(withPeripheral: aPeripheral)
        }
    }

}
