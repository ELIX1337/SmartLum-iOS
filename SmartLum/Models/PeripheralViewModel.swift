//
//  PeripheralViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class PeripheralViewModel: NSObject {
    
    public var basePeripheral: BasePeripheral
    public var tableView: UITableView
    public var selection: (PeripheralRow) -> Void
    public var dataModel = PeripheralDataModel()
    public var tableViewModel: PeripheralTableViewModel!
    public var hiddenIndexPath = HiddenIndexPath()

    init(_ withTableView:   UITableView,
         _ withPeripheral: BasePeripheral,
         _ baseDelegate:   BasePeripheralDelegate,
         _ selected:       @escaping (PeripheralRow) -> Void) {
        self.tableView = withTableView
        self.selection = selected
        self.basePeripheral = TorcherePeripheral.init(withPeripheral.peripheral, withPeripheral.centralManager)
        super.init()
        self.basePeripheral.baseDelegate = baseDelegate
        self.basePeripheral.connect()
    }
    
    public func reloadCell(for row: PeripheralRow, with animation: UITableView.RowAnimation) {
        if let indexPath = tableViewModel.getIndexPath(forRow: row) {
            tableView.reloadRows(at: [indexPath], with: animation)
        } else {
            tableView.reloadData()
        }
    }
    
    public func hideRows(rows: [PeripheralRow]) {
        //tableView.beginUpdates()
            for row in rows {
                if let rowIndex = tableViewModel.getIndexPath(forRow: row) {
                    hiddenIndexPath.row.append(rowIndex)
                }
            }
        //tableView.endUpdates()
    }
    
    public func showRows(rows: [PeripheralRow]?) {
        //tableView.beginUpdates()
            guard let array = rows else {
                hiddenIndexPath.row.removeAll()
                tableView.endUpdates()
                return
            }
            for row in array {
                if let rowIndex = tableViewModel.getIndexPath(forRow: row) {
                    hiddenIndexPath.row = hiddenIndexPath.row.filter { $0 != rowIndex }
                }
            }
        //tableView.endUpdates()
    }
    
    public func hideSections(of: [PeripheralRow]) {
        //tableView.beginUpdates()
            for section in of {
                if let sectionIndex = tableViewModel.getIndexPath(forRow: section)?.section {
                    hiddenIndexPath.section.append(sectionIndex)
                }
            }
        //tableView.endUpdates()
    }
    
    public func showSections(of: [PeripheralRow]?) {
        //tableView.beginUpdates()
            guard let array = of else {
                hiddenIndexPath.section.removeAll()
                tableView.endUpdates()
                return
            }
            for section in array {
                if let sectionIndex = tableViewModel.getIndexPath(forRow: section)?.section {
                    hiddenIndexPath.section = hiddenIndexPath.section.filter { $0 != sectionIndex }
                }
            }
        //tableView.endUpdates()
    }
    
    public func cellCallback(fromRow: PeripheralRow, withValue: Any?) { }
    
    public func peripheralIsConnected() -> Bool { basePeripheral.isConnected }
    
    public func getPeripheralName() -> String { basePeripheral.name }
    
    public func disconnect() { basePeripheral.disconnect() }
    
}

extension PeripheralViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.tableViewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.tableViewModel.sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.tableViewModel.sections[section].headerText.localized
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.tableViewModel.sections[section].footerText.localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = tableViewModel.sections[indexPath.section].rows[indexPath.row]
        tableView.register(UINib.init(nibName: row.nibName, bundle: nil), forCellReuseIdentifier: row.cellReuseID)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseID, for: indexPath) as! BaseTableViewCell
        //cell.configure(title: row.name, value: row.cellValue(from: dataModel))
        row.setupCell(cell: cell, with: dataModel)
        cell.returnValue = { value in self.cellCallback(fromRow: row, withValue: value) }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (hiddenIndexPath.section.contains(indexPath.section)) {
            return 0
        }
        if (hiddenIndexPath.row.contains(indexPath)) {
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if hiddenIndexPath.section.contains(section){
            return 0
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if hiddenIndexPath.section.contains(section){
            return 0
        }
        return UITableView.automaticDimension
    }
    
}

extension PeripheralViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.selection(tableViewModel.sections[indexPath.section].rows[indexPath.row])
    }

}


