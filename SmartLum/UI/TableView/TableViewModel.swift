//
//  TableViewModel.swift
//  SmartLum
//
//  Created by ELIX on 21.07.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//
import UIKit

// Модель таблицы
// Содержит в себе массив с секциями, которые содержат в себе массивы с ячейками. Все просто
struct TableViewModel: Equatable {
    var sections: [SectionModel]
    var type: TableViewModel.TableViewType
    
    // Возвращает IndexPath ячейки. Так как CellModel Equatable по ее ключу (key), то не должно быть никаких пересечений
    func getIndexPath(forRow: CellModel) -> IndexPath? {
        if let section = sections.filter({ $0.rows.contains(forRow)}).first,
           let sectionIndex = sections.firstIndex(of: section),
           let rowIndex = sections[sectionIndex].rows.firstIndex(of: forRow) {
            return IndexPath.init(row: rowIndex, section: sectionIndex)
        }
        return nil
    }
    
    // У секции может быть ключ (опционально), по нему возможно найти эту секцию в массиве
    func getSectionByKey(_ key: String) -> SectionModel? {
        return sections.filter{ $0.key == key }.first
    }
    
    // Удаляет ячейку по IndexPath
    mutating func deleteCell(indexPath: IndexPath) {
        sections[indexPath.section].rows.remove(at: indexPath.row)
    }
    
    // Вставляет ячейку по IndexPath
    mutating func insertCell(cell: CellModel, inSectionByKey: String, at: Int) {
        guard let sectionKey = (sections.firstIndex { $0.key == inSectionByKey }) else { fatalError("Cannot find section with key \(inSectionByKey)") }
        sections[sectionKey].rows.insert(cell, at: at)
    }
    
    // ВНИМАНИЕ КОСТЫЛЬ:
    // Есть extension для UITableView в котором определена переменная type, которая одно из этих значений
    // Нужно это для того, чтобы разделить ViewModel на три разные таблицы: для основного экрана, экрана настроек и экрана для инициализации устройства
    enum TableViewType: Int {
        case ready    = 1
        case setup    = 2
        case settings = 3
    }
}

extension TableViewModel {
    
    // Дефолтные ключи для секций с доп. инфой
    static var KEY_NOTICE_SECTION: String { get { "peripheral_notice_section_key" } }
    static var KEY_NOTICE_DETAIL_SECTION: String { get { "peripheral_notice_detail_section_key" } }
    
    // Метод, который создает секцию для доп. информации (используется для вывода ошибок устройства)
    static func createNoticeSection(withRows: [CellModel]?) -> SectionModel {
        return SectionModel(
            key: KEY_NOTICE_SECTION,
            headerText: "peripheral_notice_section_header".localized,
            footerText: "peripheral_notice_section_footer".localized,
            rows: withRows ?? [])
    }
    
    // Метод, который создает секцию для доп. информации С ПОЯСНЕНИЯМИ. По сути та же самая секция выше, но с описанием
    static func createNoticeDetailSection(withRows: [CellModel]?) -> SectionModel {
        return SectionModel(
            key: KEY_NOTICE_DETAIL_SECTION,
            headerText: "peripheral_notice_section_header".localized,
            footerText: "peripheral_notice_section_footer".localized,
            rows: withRows ?? [])
    }
    
    // Создает дефолтную ячейку для ошибок, она вставляется в NoticeSection (но можно куда угодно)
    static func createErrorCell() -> CellModel {
        return CellModel.infoCell(
            key: BasePeripheralData.errorKey,
            titleText: "peripheral_error_cell_title".localized,
            detailText: "peripheral_error_cell_code_prefix".localized,
            image: .init(systemName: "exclamationmark.circle.fill")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
            accessory: .disclosureIndicator)
    }
    
    // Создает дефолтную ячейку для ошибок С ПОЯСНЕНИЯМИ, она вставляется в NoticeDetailSection (но можно куда угодно)
    static func createErrorDetailCell(code: Int) -> CellModel {
            return CellModel.infoDetailCell(
                key: BasePeripheralData.errorDetailKey,
                titleText: "peripheral_error_description_cell_title".localized + "\(code)",
                detailText: "peripheral_error_code_\(code)_description".localized,
                image: .init(systemName: "exclamationmark.circle.fill", withConfiguration: UIImage.largeScale)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal),
                accessory: nil)
    }
        
}

// Просто массивы, в которых хранятся секции и ячейки, которые нужно скрыть
struct HiddenIndexPath {
    var section = [Int]()
    var row = [IndexPath]()
    
    mutating func clear() {
        section.removeAll()
        row.removeAll()
    }
}

// Просто массивы, в которых хранятся секции и ячейки, которые нужно скрыть
struct HiddenCells {
    var section = [SectionModel]()
    var cell = [CellModel]()
}



