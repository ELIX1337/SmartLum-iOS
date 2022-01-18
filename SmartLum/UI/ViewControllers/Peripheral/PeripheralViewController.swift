//
//  PeripheralViewController.swift
//  SmartLum
//
//  Created by ELIX on 15.10.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

/// Протокол, который гарантирует, что viewController получит viewModel и обработает нажатия по ячейкам
protocol PeripheralViewControllerProtocol {
    func viewModelInit(peripheral: BasePeripheral)
    func onCellSelected(model: CellModel)
}

extension PeripheralViewControllerProtocol {
    func onCellSelected(model: CellModel) { }
}

/// Главный ViewController устройства.
/// В нем происходит основная работа с устройством.
class PeripheralViewController: UIViewController {
    
    @objc var viewModel: PeripheralViewModel!
    
    /// Этой таблице соотвествует readyTableViewModel
    var tableView: UITableView = UITableView.init(frame: .zero, style: .grouped)
    var alert: UIAlertController?
    
    /// DataSource для Picker'a
    /// Используется когда нужно выбрать режим анимации или какое еще значение
    var pickerDataSource: TablePickerViewDataSource<PeripheralDataModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewModel?.peripheralName
        self.navigationItem.largeTitleDisplayMode = .always
        
        /// Если устройство еще не подключилось, то показываем alert
        if (!viewModel.isConnected) {
            self.showConnectionAlert()
        }
        
        addTableViewConstraints(tableView: self.tableView)
    }
    
    /// Располагаем tableView на экране
    func addTableViewConstraints(tableView: UITableView) {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.cellLayoutMarginsFollowReadableWidth      = false
        self.view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
    
    /// Этот метод вызовится когда пользователь подключится к устройству, вернется назад из расширенных настроек
    /// или когда закончит первичную настройку (инициализацию) устройства.
    /// В нем мы обновляем tableView во ViewModel.
    /// То же самое мы делаем на остальных экранах.
    override func viewWillAppear(_ animated: Bool) {
        
        /// Говорим ViewModel что теперь она работает с новой tableView
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .ready)
        
        /// Если у устройства есть экран расширенных настроек, то добавляем соответствующую кнопку
        if viewModel.peripheralSettingsAvailable {
            let btn = UIBarButtonItem.init(image: UIImage.init(systemName: "gearshape"), style: .done, target: self, action: #selector(self.openPeripheralSettings))
            self.navigationItem.rightBarButtonItem = btn
        }
    }
    
    /// Открываем расширенные настройки устройства
    @objc func openPeripheralSettings() {
        let vc = PeripheralSettingsViewController()
        /// Назначаем ViewModel для этого экрана
        vc.viewModel = self.viewModel
        navigationController?.pushViewController(vc, animated: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        /// Отключаемся от устройства когда идем обратно по навигации
        if (self.isMovingFromParent) {
            viewModel?.disconnect()
        }
    }
    
    /// Инициализируем picker.
    /// Принимает в себя массив данных, из которых будет происходить выбор.
    /// Аргумент withSelection не работает, по идее должна была быть галочка рядом с текущим выбранным элементом, но руки не дошли это реализовать
    func initPickerDataSource<T: PeripheralDataModel>(with elements: [T], callback: @escaping (T) -> Void) {
        self.pickerDataSource = TablePickerViewDataSource<PeripheralDataModel>(withItems: elements, withSelection: FlClassicAnimations.rainbow, withRowTitle: { $0.name.localized })
        {
            // Возвращаем выбранный элемент
            callback($0 as! T)
        }
    }
    
    func pushPicker<T: PeripheralDataModel>(_ dataArray: [T], _ callback: @escaping (T) -> Void) {
        
        /// Picker вылезет снизу экрана поверх текущего, но по идее это отдельный ViewController с прозрачным фоном.
        /// Можно использовать WheelPickerViewController
        let vc = TablePickerViewController()
        
        /// Создаем DataSource  для Picker'а
        initPickerDataSource(with: dataArray, callback: callback)
        
        /// Назначаем делегата и dataSource
        vc.delegate = pickerDataSource
        vc.dataSource = pickerDataSource
        
        /// Показываем Picker
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    /// Выводит ColorPicker на экране
    func pushColorPicker(_ sender: CellModel, initColor: UIColor, onColorChange: @escaping (_ color: UIColor, _ sender: Any) -> Void) {
        let vc = ColorPickerViewController()
        vc.configure(initColor: initColor, colorIndicator: nil, sender: sender, onColorChange: onColorChange)
        self.navigationController?.present(vc, animated: true, completion: nil)
    }

}

extension PeripheralViewController {
    
    public func showConnectionAlert() {
        let text = "peripheral_connecting_alert_text".localized
        self.alert = UIAlertController(title: "\(text)\(viewModel.peripheralName)", message: "", preferredStyle: .actionSheet)
        self.present(alert!, animated: false, completion: nil)
    }
    
    public func hideConnectionAlert() {
        self.alert?.dismiss(animated: true, completion: nil)
    }
    
    /// Этот Alert используется, когда пользователь нажимает на кнопку сброса настроек до заводских.
    public func showResetAlert() {
        let alert = UIAlertController(
            title: "peripheral_reset_alert_title".localized,
            message: "peripheral_reset_alert_text".localized,
            preferredStyle: .alert)
        alert.addAction(.init(
            title: "peripheral_reset_alert_confirm_button".localized,
            style: .destructive,
            handler: { _ in
                self.viewModel.setFactorySettings()
                self.navigationController?.popToRootViewController(animated: true)
            }))
        alert.addAction(.init(
            title: "peripheral_reset_alert_cancel_button".localized,
            style: .cancel,
            handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
        self.present(alert, animated: true, completion: nil)
    }
}

/// Методы делегата ViewModel
extension PeripheralViewController: PeripheralViewModelDelegate {
    
    /// Состояние инициализации устройства
    func peripheralInitState(isInitialized: Bool) {
        viewModel.dataModel.setValue(key: BasePeripheralData.initStateKey, value: isInitialized)
        viewModel.isInitialized = isInitialized
    }
    
    func peripheralDidConnect() {
        /// Можно вызвать тут, но после подключение еще идет чтение данных с устройства
        /// поэтому вызов этого метода перенесен в peripheralIsReady
        //hideConnectionAlert()
    }
    
    /// Если произошло отключение от устройства (потеря соединения),
    /// то закрываем ViewController и выводим сообщение.
    func peripheralDidDisconnect(reason: Error?) {
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
        print("Disconnect reason - \(String(describing: reason?.localizedDescription))")
    }
    
    /// Устройство подключилось, данные считаны. Все готово к работе
    func peripheralIsReady() {
        hideConnectionAlert()
        /// Если устройство не настроено (инициализировано),
        /// то выводим на экран setupViewController
        if !viewModel.isInitialized {
            if let setupViewController = PeripheralProfile.getPeripheralSetupVC(peripheral: viewModel.basePeripheral) {
                setupViewController.viewModel = viewModel
                
                /// Callback который вызывается при закрытии setupViewController.
                /// Если пользователь закрыл setupViewController не произведя настройку устройства,
                /// То закрываем и этот ViewController и выводим сообщение.
                /// Если setupViewController закрылся произведя настройку устройства,
                /// то переназначем tableView для ViewModel чтобы она работала с новой таблицей.
                setupViewController.dismiss = { gotInit in
                    if !gotInit {
                        self.navigationController?.popToRootViewController(animated: true)
                        self.navigationController?.visibleViewController?.showErrorAlert(title: "Disconnected", message: "Device setup failed")
                    } else {
                        self.viewModel.resetTableView(tableView: self.tableView, delegate: self, tableViewType: .ready)
                    }
                }
                
                navigationController?.present(setupViewController, animated: true, completion: nil)
                /// Чисто на всякий случай
                tableView.reloadData()
            }
        }
    }
    
    /// Функция DFU не была реализована (только тест). Поэтому тут пусто.
    /// По идее мы должны закрыть текущий ViewController или показать новый поверх.
    /// Затем найти через сканнер устройство, подключиться и сделать DFU. Пример DFU ViewController есть.
    func peripheralOnDFUMode() {
        print("PERIPHERAL IS ON DFU MODE")
    }
}

/// ViewController, который показыается для первичной настройки (инициализации) устройства.
class PeripheralSetupViewController: PeripheralViewController {
    
    /// Кнопка подтверждения настроек
    let confirmButton = UIButton(type: UIButton.ButtonType.roundedRect) as UIButton
    
    /// Кнопка отмены настройки
    let cancelButton = UIButton(type: UIButton.ButtonType.roundedRect) as UIButton
    
    /// Видимо для этой переменной была еще какая-то задача...
    var showConfirmButton: Bool = true
    
    /// Вызывается когда этот ViewController закрывается
    /// Несет с собой сотояние настройки (успешно или нет)
    var dismiss: (_ initState: Bool) -> Void = { initState in }
    
    /// Следим за тем, готовы ли мы отправить данные
    var readyToWriteObserve: NSKeyValueObservation?
    
    /// Следим за тем, приняло ли устройство данные
    var initSuccessObserve: NSKeyValueObservation?
    
    override func viewDidLoad() {
        tableView = UITableView.init(frame: .zero, style: .insetGrouped)
        /// Задаем тип tableView, в зависимости от него, TableViewDataSource будет использовать соответствующую TableViewModel
        tableView.tableViewType = .setup
        addTableViewConstraints(tableView: tableView)
        addCancelButton()
        
        if (showConfirmButton) {
            addConfirmButton()
            /// Если пользователь указал все настройки (заполнил все поля, выставил все слайдеры и тд),
            /// то делаем кнопку "Подтвердить" активной
            readyToWriteObserve = observe(\.viewModel.readyToWriteInitData, options: .new) { vc, newValue in
                self.confirmButton.isEnabled = newValue.newValue ?? false
            }
        }
        
        /// Если устройство успешно приняло данные, то закрываем этот ViewController
        initSuccessObserve = observe(\.viewModel?.isInitialized, options: .new) { vc, newValue in
            if (newValue.newValue == true) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /// Аналогично обычному ViewController, переопределяем tableView для ViewModel чтобы она работала уже с этой таблицой.
    override func viewWillAppear(_ animated: Bool) {
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .setup)
    }

    /// Закрываем observer'ы.
    /// Вызываем callback с соотвествующим результатом настройки (успешно или нет)
    override func viewDidDisappear(_ animated: Bool) {
        initSuccessObserve?.invalidate()
        readyToWriteObserve?.invalidate()
        if isBeingDismissed {
            dismiss(viewModel.isInitialized)
        }
        super.viewDidDisappear(animated)
    }
    
    /// Распологаем tableView
    override func addTableViewConstraints(tableView: UITableView) {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.cellLayoutMarginsFollowReadableWidth = false
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
    }
    
    /// Просто куча кода для кнопки
    private func addConfirmButton() {
        confirmButton.setTitle("button_confirm_peripheral_init".localized, for: UIControl.State.normal)
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        confirmButton.layer.cornerRadius = 10.0
        confirmButton.backgroundColor = UIColor.SLWhite
        confirmButton.tintColor = UIColor.SLDarkBlue
        confirmButton.isEnabled = false
        view.addSubview(confirmButton)
        confirmButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -5).isActive = true
        confirmButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        confirmButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    /// Просто куча кода для кнопки
    private func addCancelButton() {
        cancelButton.setTitle("button_cancel_peripheral_init".localized, for: UIControl.State.normal)
        cancelButton.addTarget(self, action: #selector(self.cancelAction), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.layer.cornerRadius = 10.0
        cancelButton.backgroundColor = UIColor.SLWhite
        cancelButton.tintColor = UIColor.SLDarkBlue
        view.addSubview(cancelButton)
        cancelButton.heightAnchor.constraint(equalToConstant: CGFloat(44)).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        cancelButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        cancelButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
    }
    
    /// Реализация происходит в классах наследниках
    @objc func confirmAction(_ sender:UIButton!) { }
    
    @objc func cancelAction(_ sender:UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

/// ViewController который показывает экран расширенных настроек устройства
class PeripheralSettingsViewController: PeripheralViewController {
            
    override func viewWillAppear(_ animated: Bool) {
        self.title = "peripheral_settings_window_title".localized
        
        /// Говорим ViewModel, что теперь она работает с новой tableView
        viewModel.resetTableView(tableView: tableView, delegate: self, tableViewType: .settings)
        
        addTableViewConstraints(tableView: self.tableView)
    }
    
    override func loadView() {
        super.loadView()
        self.navigationItem.largeTitleDisplayMode = .always
        self.tableView = UITableView.init(frame: .zero, style: .insetGrouped)
    }
    
    /// НЕ УДАЛЯТЬ! Иначе вызовет super метод в котором происходит дисконнект
    override func viewDidDisappear(_ animated: Bool) { }
    
}
