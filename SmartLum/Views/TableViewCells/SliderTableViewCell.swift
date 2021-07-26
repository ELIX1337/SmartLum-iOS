//
//  SliderTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 13.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class SliderTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static let reuseIdentifier: String = "SliderCellID"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    var returnValue: ((Any) -> Void)?
    
    func configure(title: String?, value: Any?) {
        self.titleLabel.text = title?.localized
        self.slider.value = value as? Float ?? 0.0
        self.slider.minimumValue = 0
        self.slider.maximumValue = 30
        if let value = value as? Int {
            self.slider.setValue(Float(value), animated: true)
        }
    }
    
    func defaultInit() {
    }
    
    @IBAction func onSliderValueChange(_ sender: UISlider) {
        self.returnValue?(sender.value)
    }
    
}
