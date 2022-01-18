//
//  SectionModel.swift
//  SmartLum
//
//  Created by ELIX on 14.01.2022.
//  Copyright © 2022 SmartLum. All rights reserved.
//

import UIKit

// Модель секции для UITableView
struct SectionModel: Equatable {
    var key: String?
    let headerText: String
    let footerText: String
    var rows: [CellModel]
    
    func getCellByKey(_ key: String) -> CellModel? {
        return rows.filter{ $0.cellKey == key }.first
    }

}
