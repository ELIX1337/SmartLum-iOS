//
//  ButtonTableViewCell.swift
//  SmartLum
//
//  Created by ELIX on 22.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class ButtonTableViewCell: UITableViewCell, BaseTableViewCell {
    
    static var reuseIdentifier: String = "ButtonCellID"
    
    func configure(title: String?, value: Any?) {
        
    }
    
    func defaultInit() {
        
    }
    
    
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func onButtonClick(_ sender: UIButton) {
        self.returnValue?(true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
