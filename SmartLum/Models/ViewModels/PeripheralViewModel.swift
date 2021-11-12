//
//  PeripheralViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

// Protocol for viewContoller to handle peripheral states in UI
protocol PeripheralViewModelDelegate {
    func peripheralInitState(isInitialized: Bool)
    func peripheralDidConnect()
    func peripheralDidDisconnect(reason: Error?)
    func peripheralIsReady()
    func peripheralOnDFUMode()
}

// Protocol for sub-classes (specific peripheral viewModel) to build peripheral-specific tableView
protocol PeripheralTableViewModelDataSourceAndDelegate {
    func callback(from cell: PeripheralCell, with value: Any?, in tableView: UITableView)
    func readyTableViewModel() -> PeripheralTableViewModel
    func setupTableViewModel() -> PeripheralTableViewModel?
    func settingsTableViewModel() -> PeripheralTableViewModel?
}

@objc class PeripheralViewModel: NSObject {
    
    public var basePeripheral: BasePeripheral!
    public var delegate: PeripheralViewModelDelegate
    public var tableViewDataSourceAndDelegate: PeripheralTableViewModelDataSourceAndDelegate?
    public var dataModel: PeripheralData!
    public var tableView: UITableView
    public var onCellSelected: (PeripheralCell) -> Void
    public lazy var hiddenIndexPath = HiddenIndexPath()
    
    public lazy var readyTableViewModel:    PeripheralTableViewModel? = tableViewDataSourceAndDelegate?.readyTableViewModel()
    public lazy var setupTableViewModel:    PeripheralTableViewModel? = tableViewDataSourceAndDelegate?.setupTableViewModel()
    public lazy var settingsTableViewModel: PeripheralTableViewModel? = tableViewDataSourceAndDelegate?.settingsTableViewModel()
    
    public var isConnected: Bool { basePeripheral.isConnected }
    public var peripheralSettingsAvailable: Bool { tableViewDataSourceAndDelegate?.settingsTableViewModel() != nil }
    public var peripheralName: String { basePeripheral.name }
    
    @objc dynamic public var readyToWriteInitData: Bool = false
    @objc dynamic public var isInitialized: Bool = true
    
    init(_ withTableView:  UITableView,
         _ withPeripheral: BasePeripheral,
         _ delegate:       PeripheralViewModelDelegate,
         _ selected:       @escaping (PeripheralCell) -> Void) {
        self.tableView = withTableView
        self.onCellSelected = selected
        self.delegate = delegate
        self.basePeripheral = withPeripheral
        self.basePeripheral.connect()
        super.init()
        self.basePeripheral.baseDelegate = self
    }
    
    public func resetTableView(tableView: UITableView, delegate: PeripheralViewModelDelegate, tableViewType: PeripheralTableViewModel.TableViewType) {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        self.delegate = delegate
        self.tableView.tableViewType = tableViewType
        self.tableView.reloadData()

    }
        
    internal func getTableViewModel(type: PeripheralTableViewModel.TableViewType) -> PeripheralTableViewModel? {
        switch type {
        case .ready:    return readyTableViewModel
        case .settings: return settingsTableViewModel
        case .setup:    return setupTableViewModel
        }
    }
    
    public func reloadCell(for row: PeripheralCell, with animation: UITableView.RowAnimation) {
        if let indexPath = getTableViewModel(type: tableView.tableViewType)?.getIndexPath(forRow: row) {
            tableView.reloadRows(at: [indexPath], with: animation)
        } else {
            tableView.reloadData()
        }
    }
    
    public func hideCell(rows: [PeripheralCell], rowsSection: [PeripheralCell]?) {
        hideRows(rows: rows)
        if let section = rowsSection {
            hideSections(of: section)
        }
    }
    
    private func hideRows(rows: [PeripheralCell]) {
        let indexPaths = rows.map { getTableViewModel(type: tableView.tableViewType)?.getIndexPath(forRow: $0) }.compactMap { $0 }
        showRows(rows: nil)
        showSections(of: nil)
        hiddenIndexPath.row = indexPaths
        tableView.reloadRows(at: indexPaths, with: .top)
    }
    
    private func showRows(rows: [PeripheralCell]?) {
        guard let array = rows else {
            hiddenIndexPath.row.removeAll()
            tableView.reloadData()
            return
        }
        for row in array {
            if let rowIndex = getTableViewModel(type: tableView.tableViewType)?.getIndexPath(forRow: row) {
                hiddenIndexPath.row = hiddenIndexPath.row.filter { $0 != rowIndex }
                tableView.reloadRows(at: [rowIndex], with: .top)
            }
        }
    }
    
    private func hideSections(of: [PeripheralCell]) {
        let indexPaths = of.map { getTableViewModel(type: tableView.tableViewType)?.getIndexPath(forRow: $0) }.compactMap { $0?.section }
        hiddenIndexPath.section = indexPaths
        hiddenIndexPath.section.forEach { tableView.reloadSections(IndexSet(integer: $0), with: .top) }
    }
    
    private func showSections(of: [PeripheralCell]?) {
        guard let array = of else {
            hiddenIndexPath.section.removeAll()
            tableView.reloadData()
            return
        }
        for section in array {
            if let sectionIndex = getTableViewModel(type: tableView.tableViewType)?.getIndexPath(forRow: section)?.section {
                hiddenIndexPath.section = hiddenIndexPath.section.filter { $0 != sectionIndex }
                tableView.reloadSections(IndexSet(integer: sectionIndex), with: .none)
            }
        }
    }
    
    func insertCell(_ model: inout PeripheralTableViewModel, _ at: IndexPath, _ cell: PeripheralCell) {
        model.sections[at.section].rows.insert(cell, at: at.row)
        if model.type == tableView.tableViewType {
            tableView.insertRows(at: [at], with: .top)
        }
    }
    
    func deleteCells(_ model: inout PeripheralTableViewModel, _ at: [IndexPath]) {
        at.forEach { indexPath in
            model.sections[indexPath.section].rows.remove(at: indexPath.row)
            if model.sections[indexPath.section].rows.isEmpty {
                deleteSection(&model, IndexSet(integer: indexPath.section))
            } else {
                if model.type == tableView.tableViewType {
                    tableView.deleteRows(at: at, with: .top)
                }
            }
        }
    }
    
    func insertSection( _ model: inout PeripheralTableViewModel, _ at: IndexSet, _ section: PeripheralSection) {
        if !model.sections.contains(section) {
            model.sections.insert(section, at: at.first!)
            if model.type == tableView.tableViewType {
                tableView.insertSections(at, with: .top)
            }
        }
    }
    
    func deleteSection( _ model: inout PeripheralTableViewModel, _ at: IndexSet) {
        model.sections.remove(at: at.first!)
        if model.type == tableView.tableViewType {
            tableView.deleteSections(at, with: .top)
        }
    }
    
    func insertErrorCell(_ model: inout PeripheralTableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_SECTION) {
            if noticeSection.getCellByKey(BasePeripheralData.errorKey) == nil {
                let sectionIndex = model.sections.firstIndex(of: noticeSection)!
                let errorCell = PeripheralTableViewModel.createErrorCell()
                insertCell(&model, IndexPath(row: 0, section: sectionIndex), errorCell)
            }
        } else {
            let noticeSection = PeripheralTableViewModel.createNoticeSection(withRows: [PeripheralTableViewModel.createErrorCell()])
            insertSection(&model, IndexSet(integer: 0), noticeSection)
        }
    }
    
    func insertErrorDetailCell(_ model: inout PeripheralTableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            if (!noticeSection.rows.contains(PeripheralTableViewModel.createErrorDetailCell(code: code))) {
                let sectionIndex = model.sections.firstIndex(of: noticeSection)!
                let errorDetailCell = PeripheralTableViewModel.createErrorDetailCell(code: code)
                insertCell(&model, IndexPath(row: 0, section: sectionIndex), errorDetailCell)
            }
        } else {
            insertSection(&model, IndexSet(integer: 0), PeripheralTableViewModel.createNoticeDetailSection(withRows: [PeripheralTableViewModel.createErrorDetailCell(code: code)]))
        }
    }
    
    // Removing error cell with specific errorCode
    func removeErrorCell(_ model: inout PeripheralTableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_SECTION) {
            if let sectionIndex = model.sections.firstIndex(of: noticeSection) {
                if let errorCellIndex = noticeSection.rows.firstIndex(of: PeripheralTableViewModel.createErrorCell()) {
                    deleteCells(&model, [IndexPath(row: errorCellIndex, section: sectionIndex)])
                }
            }
        }
    }
    
    // Removing error detail cell with specific errorCode
    func removeErrorDetailCell(_ model: inout PeripheralTableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            if let sectionIndex = model.sections.firstIndex(of: noticeSection) {
                if let errorDetailCellIndex = noticeSection.rows.firstIndex(of: PeripheralTableViewModel.createErrorCell()) {
                    deleteCells(&model, [IndexPath(row: errorDetailCellIndex, section: sectionIndex)])
                }
            }
        }
    }
    
    // Removing all error cells
    func removeErrorCells(_ model: inout PeripheralTableViewModel) {
        // if model contains noticeSection
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_SECTION) {
            // if model contains errorCell
            let errorCells = noticeSection.rows.filter { $0.cellKey == BasePeripheralData.errorKey }
            let errorCellsIndexes = errorCells.map { $0.getIndexPath(fromModel: model) }
            let noNil = errorCellsIndexes.compactMap { $0 }
            deleteCells(&model, noNil)
        }
    }
    
    // Removing all errorDetail cells
    func removeErrorDetailCells(_ model: inout PeripheralTableViewModel) {
        // if model contains noticeSection
        if let noticeSection = model.getSectionByKey(PeripheralTableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            // if model contains errorDetailCell
            let errorCells = noticeSection.rows.filter { $0.cellKey == BasePeripheralData.errorDetailKey }
            let errorCellsIndexes = errorCells.map { $0.getIndexPath(fromModel: model) }
            let noNil = errorCellsIndexes.compactMap { $0 }
            deleteCells(&model, noNil)
        }
    }
    
    private func defaultCellCallback(fromRow: PeripheralCell, withValue: Any?) {
        switch fromRow.cellKey {
        case BasePeripheralData.errorKey:
            onCellSelected(fromRow)
            break
        default: break
        }
    }
    
    // Common public API functions
    public func disconnect() { basePeripheral.disconnect() }
    
    public func setFactorySettings() { basePeripheral.setFactorySettings() }
    
    public func enableDFU() { }
    
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
        return getTableViewModel(type: tableView.tableViewType)?.sections.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].rows.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].headerText.localized ?? ""
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].footerText.localized ?? ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let row = getTableViewModel(type: tableView.tableViewType)?.sections[indexPath.section].rows[indexPath.row] {
            tableView.register(UINib.init(nibName: row.nibName, bundle: nil), forCellReuseIdentifier: row.cellReuseID)
            let cell = tableView.dequeueReusableCell(withIdentifier: row.cellReuseID, for: indexPath) as! BaseTableViewCell
            row.configure(cell: cell, with: dataModel)
            cell.returnValue = { value in
                self.defaultCellCallback(fromRow: row, withValue: value)
                self.tableViewDataSourceAndDelegate?.callback(from: row, with: value, in: tableView)
            }
            return cell
        } else {
            return UITableViewCell.init()
        }
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
        if let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell {
            cell.didSelect()
        }
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedCell = getTableViewModel(type: tableView.tableViewType)?.sections[indexPath.section].rows[indexPath.row] {
            onCellSelected(selectedCell)
        }
    }
    
}

// Delegating common peripheral commands
extension PeripheralViewModel: BasePeripheralDelegate {

    func peripheralError(code: Int) {
        dataModel.setValue(key: BasePeripheralData.errorKey, value: code)
        tableView.beginUpdates()
                if readyTableViewModel != nil {
                    code != 0 ? insertErrorCell(&readyTableViewModel!, code: code) :
                    removeErrorCells(&readyTableViewModel!)
                }
                if settingsTableViewModel != nil {
                    code != 0 ? insertErrorDetailCell(&settingsTableViewModel!, code: code) :
                    removeErrorDetailCells(&settingsTableViewModel!)
                }
                if setupTableViewModel != nil {
                    code != 0 ? insertErrorDetailCell(&setupTableViewModel!, code: code) :
                    removeErrorDetailCells(&setupTableViewModel!)
                }
        tableView.endUpdates()
    }
    
    func peripheralInitState(isInitialized: Bool) {
        if !isInitialized {
            if setupTableViewModel != nil {
                tableView.beginUpdates()
                insertSection(&setupTableViewModel!, IndexSet(integer: 0), .init(key: "initKey", headerText: "", footerText: "", rows: [.infoCell(
                    key: "init_info_cell",
                    titleText: "Device requres setup",
                    detailText: nil,
                    image: .init(systemName: "info.circle.fill")?.withTintColor(.SLYellow, renderingMode: .alwaysOriginal),
                    accessory: nil)]))
                tableView.endUpdates()
            }
        }
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
        dataModel.setValue(key: BasePeripheralData.firmwareVersionKey, value: version)
    }
    
    func peripheralOnDFUMode() {
        delegate.peripheralOnDFUMode()
    }
}
