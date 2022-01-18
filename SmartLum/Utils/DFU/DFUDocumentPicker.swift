//
//  DFUDocumentPicker.swift
//  SmartLum
//
//  Created by Tim on 25.02.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import iOSDFULibrary

/// ВНИМАНИЕ: Этот код использовался при тестировании DFU. В продакшене он не применяется.
/// Этот класс используется для поиска файла прошивки на смартфоне.
class DocumentPicker<T>: NSObject, UIDocumentPickerDelegate {
    
    typealias Callback = (Result<T, Error>) -> ()
    private (set) var callback: Callback!
    let types: [String]
    
    init(documentTypes: [String]) {
        types = documentTypes
        super.init()
    }
    
    func openDocumentPicker(presentOn controller: UIViewController, callback: @escaping Callback) {
        
        let documentPickerVC = UIDocumentPickerViewController(documentTypes: types, in: .import)
        documentPickerVC.delegate = self
        controller.present(documentPickerVC, animated: true)
        self.callback = callback
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
    }
}

class DFUDocumentPicker: DocumentPicker<DFUFirmware> {
    
    init() {
        super.init(documentTypes: ["com.pkware.zip-archive"])
    }
    
    override func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard let firmware = DFUFirmware(urlToZipFile: url) else {
            callback(.failure(QuickError(message: "Can not create Firmware")))
            return
        }
        
        callback(.success(firmware))
    }
}
