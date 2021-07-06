//
//  TablePickerViewController.swift
//  SmartLum
//
//  Created by Tim on 12.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol TablePickerDelegate {
    func getSelection(at index: Int, in array: [Int:String])
}

class TablePickerViewController: UIViewController,
                                     UITableViewDelegate,
                                     UITableViewDataSource {
    
    var tableView:UITableView = UITableView()
    var delegate:TablePickerDelegate?
    var dataArray:(array: [Int:String], index: Int?)?
    private var lastSelection:IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.largeTitleDisplayMode = .never
        tableView = UITableView(frame: UIScreen.main.bounds, style: UITableView.Style.plain)
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.reloadData()
    }
    
    // MARK: - TableView protocol
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let arraySize = dataArray?.array.count {
            return arraySize
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
             return UITableViewCell(style: .default, reuseIdentifier: "cell")
             }
             return cell
         }()
        cell.textLabel?.text = dataArray?.array[indexPath.row + 1]?.localized
        
        if let a = dataArray?.index {
            if indexPath.row == a - 1 {
                cell.accessoryType = .checkmark
                lastSelection = indexPath
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.getSelection(at: indexPath.row + 1, in: dataArray!.array)
        if let index = lastSelection {
            if index != indexPath {
                tableView.cellForRow(at: index)?.accessoryType = .none
            }
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        lastSelection = indexPath
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
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
    private var selectedIndexPath:IndexPath = IndexPath.init(row: 1, section: 0)
    
    public init(withItems originalItems: [T],
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
        if indexPath == selectedIndexPath {
            cell.accessoryType = UITableViewCell.AccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCell.AccessoryType.none
        }
        cell.textLabel?.text = items[indexPath.row].title.localized
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == selectedIndexPath { return }
        let newCell = tableView.cellForRow(at: indexPath)
        if newCell?.accessoryType == UITableViewCell.AccessoryType.none {
            newCell?.accessoryType = UITableViewCell.AccessoryType.checkmark
        }
        let oldCell = tableView.cellForRow(at: selectedIndexPath)
        if oldCell?.accessoryType == UITableViewCell.AccessoryType.checkmark {
            oldCell?.accessoryType = UITableViewCell.AccessoryType.none
        }
        selectedIndexPath = indexPath
        self.selected(items[indexPath.row].type)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
    }
    
}
