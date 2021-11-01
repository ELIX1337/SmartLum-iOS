//
//  ErrorDetailTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 25.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class ErrorDetailTableViewCell: UITableViewCell, BaseTableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    static var reuseIdentifier: String = "ErrorDetailCellID"
    
    func configure(title: String?, value: Any?) {
    }
    
    func defaultInit() {
    }
    
    var returnValue: ((Any) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @objc func openPeripheralSettings() {
        self.descriptionLabel.isHidden.toggle()
    }
    
    func didSelect() {
        descriptionLabel.isHidden.toggle()
        print("Selected")
    }
    
}
