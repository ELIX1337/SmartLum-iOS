//
//  PickerViewController.swift
//  SmartLum
//
//  Created by ELIX on 06.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class PickerViewController: PopupPickerViewController {

    public var delegate: UIPickerViewDelegate?
    public var dataSource: UIPickerViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.frame = CGRect(x: 0,
                                     y: UIScreen.main.bounds.height - 300,
                                     width: UIScreen.main.bounds.width,
                                     height: 300)
        let pickerView = UIPickerView(frame: containerView.frame)
        self.view.addSubview(pickerView)
        pickerView.backgroundColor = UIColor.clear
        pickerView.delegate = self.delegate
        pickerView.dataSource = self.dataSource
    }
}

class TtablePickerViewController: PopupPickerViewController {
    
    public var delegate: UITableViewDelegate?
    public var dataSource: UITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
        tableView.allowsMultipleSelection = false

        self.containerView.addSubview(tableView)
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.bottom,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.containerView,
                           attribute: NSLayoutConstraint.Attribute.bottomMargin,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.top,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.containerView,
                           attribute: NSLayoutConstraint.Attribute.top,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.containerView,
                           attribute: NSLayoutConstraint.Attribute.leading,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        NSLayoutConstraint(item: tableView,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           relatedBy: NSLayoutConstraint.Relation.equal,
                           toItem: self.containerView,
                           attribute: NSLayoutConstraint.Attribute.trailing,
                           multiplier: 1.0,
                           constant: 0.0).isActive = true
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.reloadData()
        print("sdf \(tableView.dataSource)")
    }
    
}

