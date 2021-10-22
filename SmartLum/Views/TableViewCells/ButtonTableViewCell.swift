//
//  ButtonTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 22.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static let reuseIdentifier: String = "ButtonCellID"
    var returnValue: ((Any) -> Void)?
    
    @IBOutlet weak var button: UIButton!
    
    func configure(title: String?, value: Any?) {
        
    }
    
    func defaultInit() {
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        self.returnValue?(true)
    }
    
}
