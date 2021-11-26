//
//  ButtonTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 22.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static var nibName: String = "ButtonTableViewCell"
    static let reuseIdentifier: String = "ButtonCellID"
    var callback: ((Any) -> Void)?
    
    @IBOutlet weak var button: UIButton!
    
    func configure(title: String?, value: Any?) { }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        self.callback?(true)
    }
    
}
