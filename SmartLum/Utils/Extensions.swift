//
//  UIColors.swift
//  SmartLum
//
//  Created by Tim on 04/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import CoreBluetooth

// Расширения для упрощения всякой работы.


/// Эта функция не применяется в приложении.
/// Используются ее аналоги.
/// Должна конвертировать числа в байты для дальнейшей отправки по Bluetooth.
func bytes<U: FixedWidthInteger,V: FixedWidthInteger>(
    of value    : U,
    to type     : V.Type,
    droppingZeros: Bool
    ) -> [V]{

    let sizeInput = MemoryLayout<U>.size
    let sizeOutput = MemoryLayout<V>.size

    precondition(sizeInput >= sizeOutput, "The input memory size should be greater than the output memory size")

    var value = value
    let a =  withUnsafePointer(to: &value, {
        $0.withMemoryRebound(
            to: V.self,
            capacity: sizeInput,
            {
                Array(UnsafeBufferPointer(start: $0, count: sizeInput/sizeOutput))
        })
    })

    let lastNonZeroIndex =
        (droppingZeros ? a.lastIndex { $0 != 0 } : a.indices.last) ?? a.startIndex

    return Array(a[...lastNonZeroIndex].reversed())
}

extension String {
    
    /// Ищет в Localizable нужную строку.
    /// Работать нужно аккуратно, проверить что все сходится с Localizable (во всех языках) чтобы не было непонятного текста в приложении.
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func localized(withComment:String) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: withComment)
    }
    
}

extension Data {
    
    /// Превращает Data в Int
    /// Используется чтобы перевести полученные по Bluetooth данные в нормальный вид.
    func toInt() -> Int {
        let decimalValue = self.reduce(0) { v, byte in
            return v << 8 | Int(byte)
        }
        return decimalValue
    }
    
    func toArray() -> [UInt8] {
        return Array(self)
    }
    
}

extension UIColor {
    
    /// Конвертирует UIColor в массив из байтов (3 байта RGB).
    /// Используется чтобы отправить цвет по Bluetooth.
    func toData() -> Data {
        let packet: [UInt8] = [UInt8(self.rgb()!.red   * 255),
                               UInt8(self.rgb()!.green * 255),
                               UInt8(self.rgb()!.blue  * 255)]
        return Data(bytes: packet, count: packet.count)
    }
    
    /// Переводит UIColor в RGB tuple
    func rgb() -> (red:Float, green:Float, blue:Float)? {
        var fRed   : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue  : CGFloat = 0
        var fAlpha : CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed   = Float(fRed)
            let iGreen = Float(fGreen)
            let iBlue  = Float(fBlue)
            return (red:iRed, green:iGreen, blue:iBlue)
        } else {
            return nil
        }
    }
    
    /// Принимает в себя 2 цвета (для светлой и темной темы).
    /// В зависимости от того, какая тема стоит на устройстве, вернет нужный цвет.
    static func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                return traitCollection.userInterfaceStyle == .light ? light : dark
            }
        } else {
            return light
        }
    }
    
    static let SLYellow = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.2509803922, alpha: 1)
    static let SLBlue = #colorLiteral(red: 0.1529411765, green: 0.1960784314, blue: 0.2392156863, alpha: 1)
    static let SLDarkBlue = #colorLiteral(red: 0.1137254902, green: 0.1450980392, blue: 0.1764705882, alpha: 1)
    static let SLRed = #colorLiteral(red: 0.9567440152, green: 0.2853084803, blue: 0.3770255744, alpha: 1)
    static let SLWhite = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let SLTest = #colorLiteral(red: 1, green: 0.8117647059, blue: 0.2509803922, alpha: 1)
}

extension Numeric {
    
    /// Переводит любое число (не только Int) в байты.
    /// ОСТОРОЖНО: Работает не так как toDynamicSizeData()&
    /// Не используется.
    func toData() -> Data {
        var source = self
        return .init(bytes: &source, count: MemoryLayout<Self>.size)
    }
    
    init<D: DataProtocol>(_ data: D) {
        var value: Self = .zero
        let size = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0)} )
        assert(size == MemoryLayout.size(ofValue: value))
        self = value
    }
}

extension UnsignedInteger {
    
    init(_ bytes: [UInt8]) {
        precondition(bytes.count <= MemoryLayout<Self>.size)
        var value: UInt64 = 0

        for byte in bytes {
            value <<= 8
            value |= UInt64(byte)
        }
        self.init(value)
    }
    
}

extension Int {
    
    /// Переводит Integer в массив байтов, но динамического размера (1 или 2).
    /// Дефолтные методы, в раширениях выше, создают массив из 8 байтов (именно столько памяти и нужно для хранения Integer),
    /// Но, например, для числа 10, достаточно 1 байта (0-255), поэтому остальные 7 байтов не нужны.
    /// Данный метод создаст столько, сколько нужно (максимум 2, так как больше и не понадобилось).
    /// Сделано для оптимизации передачи данных по Bluetooth (меньший размер пакета для маленьких данных).
    func toDynamicSizeData() -> Data {
        if (0...255).contains(self) {
            var source = UInt8(self)
            return .init(bytes: &source, count: MemoryLayout<UInt8>.size)
        }
        var array = [UInt8](repeating: 0, count:2)
        array[0] = UInt8(self >> 8)
        array[1] = UInt8(self & 0xFF)
        return Data(array)
    }
}

extension Bool {
    
    /// Переводит Bool в байты.
    /// true - 1, false - 0.
    func toData() -> Data {
        var value = self ? Data([0x1]) : Data([0x0])
        return Data(bytes: &value, count: value.count)
    }
}

extension StringProtocol {
    
    /// Переводит строку в байты (UTF8). Не используется нигде.
    func toData() -> Data {
        return .init(utf8)
    }
}

extension DataProtocol {
    
    /// Переводит байты в строку по заданной кодировке.
    /// Не используется нигде.
    func toString(encoding: String.Encoding?) -> String? {
        return String(bytes: self, encoding: encoding ?? .utf8)
    }
    
    /// Переводит байты в UIColor.
    /// Используется при получении цвета от устройства по Bluetooth.
    /// Ожидает массив из 3 байт (RGB), иначе Exception.
    func toUIColor() -> UIColor {

        return UIColor(
            red:   CGFloat(self[0 as! Self.Index])/255,
            green: CGFloat(self[1 as! Self.Index])/255,
            blue:  CGFloat(self[2 as! Self.Index])/255,
            alpha: 1.0)
    }
    
    /// Переводит байты в Bool.
    /// Если значение равно 0 - false, иначе true.
    /// То есть может быть абсолютно любое число для true.
    func toBool() -> Bool {
        return self.toUInt8() != 0
    }
    
    /// В этом варианте мы четко ждем 1 байт.
    /// Если значение 1 - true, иначе false.
    /// То есть тут условия жестче, для корректной работы нужно слать исключительно 1 или 0.
//    func toBool() -> Bool {
//        return self[0 as! Self.Index] == 0x1
//    }
    
    func value<N: Numeric>() -> N { .init(self) }
    
    /// Это вроде нигде не используется, но лежит на всякий случай.
    func toInt() -> Int { value() }
    func toInt32() -> Int32 { value() }
    func toUInt8() -> UInt8 { value() }
    func toFloat() -> Float { value() }
    func toCGFloat() -> CGFloat { value() }
    func toDouble() -> Double { value() }
    func toDecimal() -> Decimal { value() }
}

extension Array where Element: Hashable {
    
    /// Ищет различия между массивами
    func difference(from other: [Element]) -> [Element] {
        let thisSet = Set(self)
        let otherSet = Set(other)
        return Array(thisSet.symmetricDifference(otherSet))
    }
}

extension UIImage {
    
    /// Возвращает увеличенный вариант изображения.
    /// Использутся для установки иконок для ячеек tableView.
    static var largeScale: SymbolConfiguration { UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large) }
}

extension UIViewController {
    
    /// Метод для быстрого вывода Alert для экрана
    public func showErrorAlert(title: String, message: String) {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default, handler: { _ in alert.dismiss(animated: true, completion: nil) }))
        self.present(alert, animated: true, completion: nil)
    }
}
