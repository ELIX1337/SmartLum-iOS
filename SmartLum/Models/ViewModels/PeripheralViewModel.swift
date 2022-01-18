//
//  PeripheralViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

/// Делегат (ViewController) который обработает в UI важные события
protocol PeripheralViewModelDelegate {
    
    /// Сообщает что устройство подключилось
    func peripheralDidConnect()
    
    /// Сообщает состояние устройства (настроено ли оно)
    func peripheralInitState(isInitialized: Bool)
    
    /// Сообщает что устройство отключилось
    func peripheralDidDisconnect(reason: Error?)
    
    /// Сообщает что устройство готово к работе (была считана вся информация с него)
    func peripheralIsReady()
    
    /// Сообщает что устройство перешло в режим обновления прошивки (не реализовано)
    func peripheralOnDFUMode()
}

/// Базовая ViewModel периферийного устройства.
/// Он нее наследуются ViewModel для конкретных устройств, в которых описываются UI (TableView) и методы чтения записи для конкретных устройств.
/// Примечание: Хотел реализовать автосборку UI в зависимости от Bluetooth стэка устройства чтобы не кодить на каждое устройство интерфейс, который по факту повторяется
///
/// Внимание! Местами говнокод!
@objc class PeripheralViewModel: NSObject {
    
    // UI
    /// TableView которым будет управлять эта ViewModel.
    /// TableView меняется в зависимости от экрана (главный экран устройства, экран настроек (если есть), экран инициализации устройства (если есть) ).
    /// Эти три экрана - три разных ViewController'а с собственными tableView. Когда происходит переход между ними, они переопределяют эту переменную.
    /// Получается такая штука: одна ViewModel управляет тремя разными экранами (tableView).
    /// Реализация меня не устраивает, но это работает.
    public var tableView: UITableView
    
    /// Скрытые ячейки tableView хранятся в этом массиве.
    /// Они не удаляются из dataSource, а всего лишь имеют высоту равную 0
    private var hiddenCells: [CellModel] = []
    
    /// Нужно для того, чтобы tableView правильно рассчитало высоту ячейки.
    /// Нашел решение в интернете и не вникал в подробности, без него ячейки имеют корявую высоту и вроде анимации изменения тоже начинают баговать.
    private var heightAtIndexPath = Dictionary<IndexPath, CGFloat>()
    
    /// Передает ViewController'у ячейку, которая была выбрана.
    /// Нужно для того, чтобы ViewController сделал навигацию или еще какое-нибудь действие в UI.
    /// Используется для ячеек с ошибками (ведет в описание ошибки), выбора цвета (открывает ColorPicker) и тд.
    public var onCellSelected: (CellModel) -> Void

    /// Костыль.
    /// Это модели tableView для тех самых трех экранов, о которых говорилось выше.
    /// Эти модели инициализируются уже в классах-наследниках данной ViewModel.
    public var readyTableViewModel:    TableViewModel?
    public var setupTableViewModel:    TableViewModel?
    public var settingsTableViewModel: TableViewModel?
    
    // Device
    /// Bluetooth-устройство с которым мы общаемся
    public var basePeripheral: BasePeripheral!
    public var delegate: PeripheralViewModelDelegate
    
    /// Костыль для работы с tableView.
    /// Здесь хранятся данные с устройства в формате ключ-значение.
    /// Ячейки tableView (CellModel) тоже имеют уникальные ключи, которые соответсвуют этим ключам (синхронизируется в классах-наследниках).
    /// При чтении-записи с устройства, данные обновляются и обновляются ячейки.
    public var dataModel: PeripheralDataStorage!
    
    /// Переменная хранящая состояние соединения с устройством
    public var isConnected: Bool { basePeripheral.isConnected }
    
    /// Переменная которая говорит - "У этого устройства есть/отсуствует экран расширенных настроек".
    /// Если true, то ViewController добавит кнопку наверху навигации, которая будет открывать этот экран (ViewController)
    public var peripheralSettingsAvailable: Bool { settingsTableViewModel != nil }
    
    /// Имя устройства
    public var peripheralName: String { basePeripheral.name }
    
    /// Observable переменная, которая используется для того, чтобы во время первичной настройки (инициализации)
    /// устройства, включать или отключать кнопку "Подтвердить" (PeripheralSetupViewController).
    /// Сделано для того, чтобы пользователь обязательно указал настройки устройства, а не просто щелкнул чтобы пройти дальше.
    /// Значение данной переменной устанавливается в классах-наследниках и я реализовал это максмально тупо и топорно.
    @objc dynamic public var readyToWriteInitData: Bool = false
    
    /// Observable переменная, которая хранит в себе состояние инициализации устройства.
    @objc dynamic public var isInitialized: Bool = true
    
    init(_ withTableView:  UITableView,
         _ withPeripheral: BasePeripheral,
         _ delegate:       PeripheralViewModelDelegate,
         _ selected:       @escaping (CellModel) -> Void) {
        self.tableView = withTableView
        self.onCellSelected = selected
        self.delegate = delegate
        self.basePeripheral = withPeripheral
        self.basePeripheral.connect()
        super.init()
        self.basePeripheral.baseDelegate = self
    }
    
    /// Метод, который заменяет tableView на другую.
    /// Используется в тех самых трех ViewController'ах в методах viewDidLoad
    public func resetTableView(tableView: UITableView, delegate: PeripheralViewModelDelegate, tableViewType: TableViewModel.TableViewType) {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView = tableView
        self.delegate = delegate
        self.tableView.tableViewType = tableViewType
        self.tableView.reloadData()
    }
      
    /// Костыль.
    /// Используется в UITableViewDataSource.
    /// Принцип работы: каждое tableView в трех ViewController'ах имеет поле tableViewType (ready, settings, setup).
    /// UITableViewDataSource в своих методах делегата спрашивает у tableView какого она типа и в зависимости от этого использует соответствующую модель таблицы.
    /// По сути метод просто синхронизирует работу UITableViewDataSource и трех таблиц, так как они постоянно меняются при смене экрана.
    internal func getTableViewModel(type: TableViewModel.TableViewType) -> TableViewModel? {
        switch type {
        case .ready:    return readyTableViewModel
        case .settings: return settingsTableViewModel
        case .setup:    return setupTableViewModel
        }
    }
    
    /// Проверяет, готово ли устройство для записи данных для первичной настройки (инициализации).
    /// Так как запись этих данных происходит по кнопке "Подтвердить", которая активна только тогда, когда пользователь указал все данные,
    /// то нужно мониторить момент, когда это становится возможным
    internal func checkInitWrite() {
        readyToWriteInitData = requiresInit()
    }
    
    /// Функция, которая говорит, требует ли устройство первичной настройки (инициализации).
    /// По дефолту не требует.
    /// Если требует, то должна переопределиться в классе-наследнике.
    internal func requiresInit() -> Bool {
        return false
    }
    
    /// Обновляет ячейку в таблице
    public func updateCell(for row: CellModel, with: UITableView.RowAnimation) {
        guard let indexPath = self.getTableViewModel(type: self.tableView.tableViewType)?.getIndexPath(forRow: row) else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell else { return }
        guard with != .none else {
            row.configure(cell: cell, with: dataModel)
            return
        }
        tableView.reloadRows(at: [indexPath], with: with)
    }
    
    /// Скрывает ячейки в таблице (ставит высоту в ноль)
    public func hideCells(cells: [CellModel], inModel: TableViewModel) {
        let currentModel = getTableViewModel(type: tableView.tableViewType) == inModel
        var indexes = [IndexPath]()
        cells.forEach { cell in
            if let index = inModel.getIndexPath(forRow: cell) {
                indexes.append(index)
                hiddenCells.append(cell)
            } else {
                fatalError("Cannot find cell \(cell.cellKey) in model")
            }
        }
        /// Если таблица, в которой нужно скрыть ячейки, сейчас показывается на экране,
        /// то обновляем ячейки
        if currentModel {
            tableView.reloadRows(at: indexes, with: .middle)
        }
    }
    
    /// Показывает ячейки (ставит высоте нормальное значение)
    public func showCells(cells: [CellModel], inModel: TableViewModel) {
        let currentModel = getTableViewModel(type: tableView.tableViewType) == inModel
        var indexes = [IndexPath]()
        cells.forEach { cell in
            if let index = inModel.getIndexPath(forRow: cell) {
                indexes.append(index)
                hiddenCells.removeAll { $0.cellKey == cell.cellKey }
            } else {
                fatalError("Cannot find cell \(cell.cellKey) in model")
            }
        }
        /// Если таблица, в которой нужно показать ячейки, сейчас показывается на экране,
        /// то обновляем ячейки
        if currentModel {
            tableView.reloadRows(at: indexes, with: .middle)
        }
    }
    
    /// Показывает все ячейки в таблице
    public func showAllCells(inModel: TableViewModel) {
        let currentModel = getTableViewModel(type: tableView.tableViewType) == inModel
        var indexes = [IndexPath]()
        inModel.sections.forEach { section in
            section.rows.forEach { cell in
                indexes.append(inModel.getIndexPath(forRow: cell)!)
                hiddenCells.removeAll { $0.cellKey == cell.cellKey }
            }
        }
        /// Если таблица, в которой нужно показать ячейки, сейчас показывается на экране,
        /// то обновляем ячейки
        if currentModel {
            tableView.reloadRows(at: indexes, with: .middle)
        }
    }
    
    /// Вставляет новую ячейку в таблицу (модель таблицы).
    /// В основном используется при возникновении ошибок на устройстве (в таблицу вставляется ErrorCell).
    func insertCell(_ model: inout TableViewModel, _ at: IndexPath, _ cell: CellModel) {
        model.sections[at.section].rows.insert(cell, at: at.row)
        if model.type == tableView.tableViewType {
            tableView.insertRows(at: [at], with: .top)
        }
    }
    
    /// Удаляет ячейку из таблицы (модели таблицы).
    /// Если ячейка была единственной в секции, то удалит и секцию.
    /// В основном используется при устранении ошибок на устройстве (из таблицы удаляется ErrorCell).
    func deleteCells(_ model: inout TableViewModel, _ at: [IndexPath]) {
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
    
    /// Вставляет новую секцию в таблицу (модель таблицы).
    /// В основном используется при возникновении ошибок на устройстве (в таблицу вставляется NoticeSection с ErrorCell).
    /// Также предполагается использовать при нахождении новых версий прошивок устройства (вставится NoticeSection с соответсвующей ячейкой)
    func insertSection( _ model: inout TableViewModel, _ at: IndexSet, _ section: SectionModel) {
        if !model.sections.contains(section) {
            model.sections.insert(section, at: at.first!)
            if model.type == tableView.tableViewType {
                tableView.insertSections(at, with: .top)
            }
        }
    }
    
    /// Удаляет секцию из таблицы (модели таблицы).
    func deleteSection( _ model: inout TableViewModel, _ at: IndexSet) {
        model.sections.remove(at: at.first!)
        if model.type == tableView.tableViewType {
            tableView.deleteSections(at, with: .top)
        }
    }
    
    /// Готовый метод, который вставит ячейку с ошибкой в самый верх таблицы.
    /// Принимает в себя модель таблицы, в которую нужно вставить ячейку, и код ошибки.
    /// Вставит только если уже нет ячейки с таким кодом.
    /// Используется чтобы вставить ячейку в таблицу на основном экране.
    func insertErrorCell(_ model: inout TableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_SECTION) {
            if noticeSection.getCellByKey(BasePeripheralData.errorKey) == nil {
                let sectionIndex = model.sections.firstIndex(of: noticeSection)!
                let errorCell = TableViewModel.createErrorCell()
                insertCell(&model, IndexPath(row: 0, section: sectionIndex), errorCell)
            }
        } else {
            let noticeSection = TableViewModel.createNoticeSection(withRows: [TableViewModel.createErrorCell()])
            insertSection(&model, IndexSet(integer: 0), noticeSection)
        }
    }
    
    /// Готовый метод, который вставит ячейку с ошибкой (С ОПИСАНИЕМ) в самый верх таблицы.
    /// Принимает в себя модель таблицы, в которую нужно вставить ячейку, и код ошибки.
    /// Вставит только если уже нет ячейки с таким кодом.
    /// Используется чтобы вставить ячейку в таблицу на экране расширенных настроек.
    func insertErrorDetailCell(_ model: inout TableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            if (!noticeSection.rows.contains(TableViewModel.createErrorDetailCell(code: code))) {
                let sectionIndex = model.sections.firstIndex(of: noticeSection)!
                let errorDetailCell = TableViewModel.createErrorDetailCell(code: code)
                insertCell(&model, IndexPath(row: 0, section: sectionIndex), errorDetailCell)
            }
        } else {
            insertSection(&model, IndexSet(integer: 0), TableViewModel.createNoticeDetailSection(withRows: [TableViewModel.createErrorDetailCell(code: code)]))
        }
    }
    
    /// Удаляет указанную ячейку с ошибкой с указанной таблицы.
    /// Определяет по коду ошибки.
    func removeErrorCell(_ model: inout TableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_SECTION) {
            if let sectionIndex = model.sections.firstIndex(of: noticeSection) {
                if let errorCellIndex = noticeSection.rows.firstIndex(of: TableViewModel.createErrorCell()) {
                    deleteCells(&model, [IndexPath(row: errorCellIndex, section: sectionIndex)])
                }
            }
        }
    }
    
    /// Удаляет указанную ячейку с ошибкой (С ОПИСАНИЕМ) с указанной таблицы.
    /// Определяет по коду ошибки.
    func removeErrorDetailCell(_ model: inout TableViewModel, code: Int) {
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            if let sectionIndex = model.sections.firstIndex(of: noticeSection) {
                if let errorDetailCellIndex = noticeSection.rows.firstIndex(of: TableViewModel.createErrorCell()) {
                    deleteCells(&model, [IndexPath(row: errorDetailCellIndex, section: sectionIndex)])
                }
            }
        }
    }
    
    /// Удаляет ВСЕ ячейки с ошибками с указанной таблицы.
    func removeErrorCells(_ model: inout TableViewModel) {
        // if model contains noticeSection
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_SECTION) {
            // if model contains errorCell
            let errorCells = noticeSection.rows.filter { $0.cellKey == BasePeripheralData.errorKey }
            let errorCellsIndexes = errorCells.map { $0.getIndexPath(fromModel: model) }
            let noNil = errorCellsIndexes.compactMap { $0 }
            deleteCells(&model, noNil)
        }
    }
    
    /// Удаляет ВСЕ ячейки с ошибками (С ОПИСАНИЕМ) с указанной таблицы.
    func removeErrorDetailCells(_ model: inout TableViewModel) {
        // if model contains noticeSection
        if let noticeSection = model.getSectionByKey(TableViewModel.KEY_NOTICE_DETAIL_SECTION) {
            // if model contains errorDetailCell
            let errorCells = noticeSection.rows.filter { $0.cellKey == BasePeripheralData.errorDetailKey }
            let errorCellsIndexes = errorCells.map { $0.getIndexPath(fromModel: model) }
            let noNil = errorCellsIndexes.compactMap { $0 }
            deleteCells(&model, noNil)
        }
    }
    
    /// Публичная функция для отключения от устройства
    public func disconnect() { basePeripheral.disconnect() }
    
    /// Публичная функция, которая сбросит настройки устройства до заводских
    public func setFactorySettings() { basePeripheral.setFactorySettings() }
    
    /// Публичная функция для перевода устройства в режим обновления прошивки.
    /// Не реализована. Но это пара строк кода.
    public func enableDFU() { }
    
}

extension UITableView {
    
    /// Костыль.
    /// Переменная, которая хранит в себе тип tableView.
    /// По ней определяется, с какой TableViewModel необходимо работать UITableViewDataSource
    var tableViewType: TableViewModel.TableViewType {
        get {
            return TableViewModel.TableViewType.init(rawValue: self.tag) ?? .ready
        }
        set {
            self.tag = newValue.rawValue
        }
    }
}

extension PeripheralViewModel: UITableViewDataSource {
    
    /// Определяем количество секций в зависимости от того, какая tableView сейчас на экране
    func numberOfSections(in tableView: UITableView) -> Int {
        return getTableViewModel(type: tableView.tableViewType)?.sections.count ?? 0
    }
    
    /// Определяем количество ячеек в секций в зависимости от того, какая tableView сейчас на экране
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].rows.count ?? 0
    }
    
    /// Пишем текст в header'е секций в зависимости от того, какая tableView сейчас на экране
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].headerText.localized
    }
    
    /// Пишем текст в footer'е секций в зависимости от того, какая tableView сейчас на экране
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        getTableViewModel(type: tableView.tableViewType)?.sections[section].footerText.localized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Получаем модель ячейки из TableViewModel
        if let cellModel = getTableViewModel(type: tableView.tableViewType)?.sections[indexPath.section].rows[indexPath.row] {
            tableView.register(UINib(nibName: cellModel.nibName, bundle: nil), forCellReuseIdentifier: cellModel.cellReuseID)
            
            // Создаем ячейку
            let cell = tableView.dequeueReusableCell(withIdentifier: cellModel.cellReuseID, for: indexPath) as! BaseTableViewCell
            
            // Конфигурируем ячейку в соответствии с ее моделью
            cellModel.configure(cell: cell, with: dataModel)
            
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Сохраняем размер ячейки
        heightAtIndexPath[indexPath] = cell.frame.size.height
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        // Получаем сохраненный размер ячейки
        return heightAtIndexPath[indexPath] ?? UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Определяем, что это за ячейка
        guard let cell = getTableViewModel(type: tableView.tableViewType)?.sections[indexPath.section].rows[indexPath.row] else {
            return UITableView.automaticDimension
        }
        
        // Если эта ячейка должна быть скрыта, то ставим ее высоту в ноль (скрываем)
        if hiddenCells.contains(cell) {
            return 0
        }
        
        // Иначе ставим ей нормальную высоту
        return UITableView.automaticDimension
    }
    
    /// Проверяем секцию.
    /// Если она пустая (все ячейки в ней скрыты), то ставим высоту header'а в ноль (скрываем).
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let subArray = getTableViewModel(type: tableView.tableViewType)?.sections[section].rows else {
            return UITableView.automaticDimension
        }
        let sectionIsEmpty = subArray.allSatisfy(hiddenCells.contains)
        return sectionIsEmpty ? 0 : UITableView.automaticDimension
    }
    
    /// Проверяем секцию.
    /// Если она пустая (все ячейки в ней скрыты), то ставим высоту  footer'а в ноль (скрываем).
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let subArray = getTableViewModel(type: tableView.tableViewType)?.sections[section].rows else {
            return UITableView.automaticDimension
        }
        let sectionIsEmpty = subArray.allSatisfy(hiddenCells.contains)
        return sectionIsEmpty ? 0 : UITableView.automaticDimension
    }
    
}

extension PeripheralViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? BaseTableViewCell {
            /// Вызываем в ячейке метод didSelect()
            /// Необходимо, например, чтобы UISwitch также менял свое значение по нажанию по ячейке в которой находится
            cell.didSelect()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        /// Передаем ViewController'у ячейку, по которой было нажатие.
        /// Подробнее в описании onCellSelected
        if let selectedCell = getTableViewModel(type: tableView.tableViewType)?.sections[indexPath.section].rows[indexPath.row] {
            onCellSelected(selectedCell)
        }
    }
    
}

// Методы делегата для обработки стандартных событий переферийных устройств
extension PeripheralViewModel: BasePeripheralDelegate {

    /// Вызывается когда на устройстве произошла ошибка
    /// Вставляет ErrorCell во все tableView
    func peripheralError(code: Int) {
        print("ERROR - \(code)")
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
    
    /// Принимает состояние настройки (инициализации) устройства.
    /// Если устройство не инициализировано, то вставит ячейку с этой информацией в setupTableViewModel.
    /// В этом случае на экран выскочит PeripheralSetupViewController с setupTableViewModel.
    func peripheralInitState(isInitialized: Bool) {
        if !isInitialized {
            if setupTableViewModel != nil {
                tableView.beginUpdates()
                insertSection(&setupTableViewModel!, IndexSet(integer: 0), .init(
                    headerText: "",
                    footerText: "",
                    rows: [.infoCell(
                        key: "init_info_cell",
                        titleText: "peripheral_setup_requires_cell_text".localized,
                        detailText: nil,
                        image: .init(systemName: "info.circle.fill")?.withTintColor(.SLYellow, renderingMode: .alwaysOriginal),
                        accessory: nil)]))
                tableView.endUpdates()
            }
        }
        
        // Отправляем дальше к ViewController'у
        delegate.peripheralInitState(isInitialized: isInitialized)
    }
    
    /// Вызывается при подключении к устройству
    func peripheralDidConnect() {
        delegate.peripheralDidConnect()
    }
    
    /// Вызывается при отключении от устройства
    func peripheralDidDisconnect(reason: Error?) {
        delegate.peripheralDidDisconnect(reason: reason)
    }
    
    /// Вызывается когда все настройки с устройства были считаны и оно готово к работе
    func peripheralIsReady() {
        delegate.peripheralIsReady()
    }
    
    /// Получение версии прошивки устройства
    func peripheralFirmwareVersion(_ version: Int) {
        dataModel.setValue(key: BasePeripheralData.firmwareVersionKey, value: version)
    }
    
    /// Вызывается когда устройство переходит в режим обновления прошивки (не реализовано)
    func peripheralOnDFUMode() {
        delegate.peripheralOnDFUMode()
    }
}
