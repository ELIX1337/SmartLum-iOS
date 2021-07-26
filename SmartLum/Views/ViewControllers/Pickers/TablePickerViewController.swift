//
//  TablePickerViewController.swift
//  SmartLum
//
//  Created by Tim on 12.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class TablePickerViewController: PopupPickerViewController {
    
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
        self.containerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
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
        print("sdf \(String(describing: tableView.dataSource))")
    }
    
}

extension Array where Element: Equatable {
    func indexes(of element: Element) -> [Int] {
        return self.enumerated().filter({ element == $0.element }).map({ $0.offset })
    }
}

class TablePickerViewDataSource<T>: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    public var originalItems: [T]
    public var items: [GenericRow<T>]
    public var selected: (T) -> Void
    //private var selectedIndexPath:IndexPath = IndexPath.init(row: 0, section: 0)
    #warning("TODO: FIX SELECTION")
    
    public init(withItems originalItems: [T],
                withSelection: T,
                withRowTitle generateRowTitile: (T) -> String,
                didSelect selected: @escaping (T) -> Void) {
        self.originalItems = originalItems
        self.selected = selected
        self.items = originalItems.map {
            GenericRow<T>(type: $0, title: generateRowTitile($0))
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
             return UITableViewCell(style: .default, reuseIdentifier: "cell")
             }
             return cell
         }()
//        if indexPath == selectedIndexPath {
//            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
//        } else {
//            cell.accessoryType = UITableViewCell.AccessoryType.none
//        }
        cell.textLabel?.text = items[indexPath.row].title.localized
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        if indexPath == selectedIndexPath { return }
//        let newCell = tableView.cellForRow(at: indexPath)
//        if newCell?.accessoryType == UITableViewCell.AccessoryType.none {
//            newCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
//        }
//        let oldCell = tableView.cellForRow(at: selectedIndexPath)
//        if oldCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
//            oldCell?.accessoryType = UITableViewCell.AccessoryType.none
//        }
//        selectedIndexPath = indexPath
        self.selected(items[indexPath.row].type)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
    
}
