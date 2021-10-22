//
//  PeripheralViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

protocol PeripheralViewModelDelegate {
    func peripheralInitState(isInitialized: Bool)
    func peripheralDidConnect()
    func peripheralDidDisconnect(reason: Error?)
    func peripheralIsReady()
    func peripheralOnDFUMode()
}

@objc class PeripheralViewModel: NSObject {
    
    public var basePeripheral: BasePeripheral!
    public var tableView: UITableView
    public var delegate: PeripheralViewModelDelegate
    public var selection: (PeripheralRow) -> Void
    public var dataModel = PeripheralDataModel()
    public var hiddenIndexPath = HiddenIndexPath()
    
    public var peripheralReadyTableViewModel: PeripheralTableViewModel?
    public var peripheralSetupTableViewModel: PeripheralTableViewModel?
    public var peripheralSettingsTableViewModel: PeripheralTableViewModel?
    
    public var tableViewModel: PeripheralTableViewModel! {
        isInitialized ? peripheralReadyTableViewModel : peripheralSetupTableViewModel
    }
    public var isConnected:    Bool { basePeripheral.isConnected }
    public var peripheralName: String { basePeripheral.name }
    
    @objc dynamic public var readyToWriteInitData: Bool = false
    @objc dynamic public var isInitialized: Bool = true
    
    init(_ withTableView:  UITableView,
         _ withPeripheral: BasePeripheral,
         _ delegate:       PeripheralViewModelDelegate,
         _ selected:       @escaping (PeripheralRow) -> Void) {
        self.tableView = withTableView
        self.selection = selected
        self.delegate  = delegate
        self.basePeripheral = withPeripheral
        self.basePeripheral.connect()
        super.init()
        self.basePeripheral.baseDelegate = self
    }
    
    internal func getTableViewModel(type: PeripheralTableViewModel.TableViewType) -> PeripheralTableViewModel {
        switch type {
        case .ready:    return peripheralReadyTableViewModel!
        case .settings: return peripheralSettingsTableViewModel!
        case .setup:    return peripheralSetupTableViewModel!
        }
    }
    
    public func reloadCell(for row: PeripheralRow, with animation: UITableView.RowAnimation) {
        if let indexPath = getTableViewModel(type: tableView.tableViewType).getIndexPath(forRow: row) {
            tableView.reloadRows(at: [indexPath], with: animation)
        } else {
            tableView.reloadData()
        }
    }
    
    
    public func hideCell(rows: [PeripheralRow], rowsSection: [PeripheralRow]?) {
        hideRows(rows: rows)
        if let section = rowsSection {
            hideSections(of: section)
        }
    }
    
    private func hideRows(rows: [PeripheralRow]) {
        let indexPaths = rows.map { tableViewModel.getIndexPath(forRow: $0) }.compactMap { $0 }
        showRows(rows: nil)
        showSections(of: nil)
        hiddenIndexPath.row = indexPaths
        tableView.reloadRows(at: indexPaths, with: .top)
    }
    
    private func showRows(rows: [PeripheralRow]?) {
        guard let array = rows else {
            hiddenIndexPath.row.removeAll()
            tableView.reloadData()
            return
        }
        for row in array {
            if let rowIndex = tableViewModel.getIndexPath(forRow: row) {
                hiddenIndexPath.row = hiddenIndexPath.row.filter { $0 != rowIndex }
                tableView.reloadRows(at: [rowIndex], with: .top)
            }
        }
    }
    
    private func hideSections(of: [PeripheralRow]) {
        let indexPaths = of.map { tableViewModel.getIndexPath(forRow: $0) }.compactMap { $0?.section }
        hiddenIndexPath.section = indexPaths
        hiddenIndexPath.section.forEach { tableView.reloadSections(IndexSet(integer: $0), with: .top) }
    }
    
    private func showSections(of: [PeripheralRow]?) {
        guard let array = of else {
            hiddenIndexPath.section.removeAll()
            tableView.reloadData()
            return
        }
        for section in array {
            if let sectionIndex = tableViewModel.getIndexPath(forRow: section)?.section {
                hiddenIndexPath.section = hiddenIndexPath.section.filter { $0 != sectionIndex }
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
            }
        }
    }
    
    public func cellDataCallback(fromRow: PeripheralRow, withValue: Any?) { }
    
    public func disconnect() { basePeripheral.disconnect() }
    
}

extension UITableView {
    var tableViewType: PeripheralTableViewModel.TableViewType {
        get {
            return PeripheralTableViewModel.TableViewType.init(rawValue: self.tag) ?? .ready
        }
        set {
            self.tag = newValue.rawValue
        }
    }
}

extension PeripheralViewModel: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.getTableViewModel(type: tableView.tableViewType).sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.getTableViewModel(type: tableView.tableViewType).sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.getTableViewModel(type: tableView.tableViewType).sections[section].headerText.localized
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.getTableViewModel(type: tableView.tableViewType).sections[section].footerText.localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = getTableViewModel(type: tableView.tableViewType).sections[indexPath.section].rows[indexPath.row]
        tableView.register(UINib.init(nibName: row.nibName, bundle: nil), forCellReuseIdentifier: row.cellReuseID)
        let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseID, for: indexPath) as! BaseTableViewCell
        row.setupCell(cell: cell, with: dataModel)
        cell.returnValue = { value in self.cellDataCallback(fromRow: row, withValue: value) }
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
        self.selection(getTableViewModel(type: tableView.tableViewType).sections[indexPath.section].rows[indexPath.row])
    }
    
}

extension PeripheralViewModel: BasePeripheralDelegate {
    
    func peripheralError(code: Int) {
        dataModel.errorCode = code
        if (peripheralReadyTableViewModel != nil) {
            if (!peripheralReadyTableViewModel!.sections.contains(PeripheralTableViewModel.errorSection)) {
                tableView.beginUpdates()
                peripheralReadyTableViewModel!.sections.insert(PeripheralTableViewModel.errorSection, at: 0)
                tableView.insertSections(IndexSet(integer: 0), with: .top)
                tableView.endUpdates()
            }
        }
    }
    
    func peripheralInitState(isInitialized: Bool) {
        delegate.peripheralInitState(isInitialized: isInitialized)
    }
    
    func peripheralDidConnect() {
        delegate.peripheralDidConnect()
    }
    
    func peripheralDidDisconnect(reason: Error?) {
        delegate.peripheralDidDisconnect(reason: reason)
    }
    
    func peripheralIsReady() {
        delegate.peripheralIsReady()
    }
    
    func peripheralFirmwareVersion(_ version: Int) {
        dataModel.firmwareVersion = version
    }
    
    func peripheralOnDFUMode() {
        delegate.peripheralOnDFUMode()
    }
}
