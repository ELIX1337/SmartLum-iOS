//
//  TorchereViewController.swift
//  SmartLum
//
//  Created by Tim on 11.03.2021.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit

class TorchereViewController: UITableViewController,
                              TablePickerDelegate,
                              ColorDelegate,
                              ColorPeripheralDelegate,
                              AnimationPeripheralDelegate {
    
    func getPrimaryColor(_ color: UIColor) {
        currentPrimaryColor = color
        setColorIndication(for: primaryColorCell, with: color)
        print("Primary color \(color)")
    }
    
    func getSecondaryColor(_ color: UIColor) {
        currentSecondaryColor = color
        setColorIndication(for: secondaryColorCell, with: color)
        print("Secondary color \(color)")
    }
    
    func getRandomColor(_ state: Bool) {
        currentRandomColor = state
        print("Random color \(state)")
    }
    
    func getAnimationMode(mode: Int) {
        currentAnimation = mode
        setAnimationUI(for: mode)
        tableView.reloadData()
        print("Animation \(mode)")
    }
    
    func getAnimationOnSpeed(speed: Int) {
        currentAnimationSpeed = speed
        animationSpeedSlider.setValue(Float(speed), animated: true)
        print("Animation on speed \(speed)")
    }
    
    func getAnimationOffSpeed(speed: Int) {
        print("Animation off speed \(speed)")
    }
    
    func getAnimationDirection(direction: Int) {
        currentAnimationDirection = direction
        directionCell.detailTextLabel?.text = TorchereData.animationDirection[direction]?.localized
        print("Animation direction \(direction)")
    }
    
    func getAnimationStep(step: Int) {
        animationStepStepper.value = Double(step)
        animationStepLabel.text = String(step)
        print("Animation step \(step)")
    }
    
    
    @IBOutlet private weak var primaryColorCell: UITableViewCell!
    @IBOutlet private weak var secondaryColorCell: UITableViewCell!
    @IBOutlet private weak var animationCell: UITableViewCell!
    @IBOutlet private weak var speedCell: UITableViewCell!
    @IBOutlet private weak var directionCell: UITableViewCell!
    @IBOutlet private weak var stepCell: UITableViewCell!
    
    @IBOutlet private weak var animationSpeedSlider: UISlider!
    @IBOutlet private weak var animationStepStepper: UIStepper!
    @IBOutlet private weak var animationStepLabel: UILabel!

    private var currentPrimaryColor: UIColor?
    private var currentSecondaryColor: UIColor?
    private var randomColorSupport: Bool?
    private var currentRandomColor: Bool?
    private var currentAnimation: Int?
    private var currentAnimationSpeed: Int?
    private var currentAnimationDirection: Int?
    
    private var hidingCells = [IndexPath]()
    private var hidingSections: Int?
    
    private let alert = UIAlertController(title: "Connecting", message: "Connecting to device...", preferredStyle: .actionSheet)
    
    private enum ColorSelection {
        case primary
        case secodary
    }
    private var pickColorFor: ColorSelection = ColorSelection.primary
    
    @IBOutlet private weak var primaryColorIndicator: UIView!
    @IBOutlet private weak var secondaryColorIndicator: UIView!
    
    private var peripheral: TorcherePeripheral!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheral.connect()
        let blurEffect:UIBlurEffect!

        if #available(iOS 13.0, *) {
            blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        } else {
            blurEffect = UIBlurEffect(style: .regular)
        }

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.view.frame
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect)
        blurEffectView2.frame = self.view.frame
        secondaryColorCell.backgroundColor = currentPrimaryColor?.withAlphaComponent(0.5)
        secondaryColorCell.insertSubview(blurEffectView, at: 0)
        secondaryColorCell.layer.cornerRadius = 15
        primaryColorCell.backgroundColor = currentPrimaryColor?.withAlphaComponent(0.5)
        primaryColorCell.insertSubview(blurEffectView2, at: 0)
        primaryColorCell.layer.cornerRadius = 15

        primaryColorCell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        secondaryColorCell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !peripheral.isConnected {
            showAlert()
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        #warning("TODO: Hide colorpicker")
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isMovingFromParent {
            peripheral.disconnect()
        }
    }
    
    // MARK: - Implementation
    
    public func setPeripheral(_ peripheral: TorcherePeripheral) {
        self.peripheral = peripheral
        title = peripheral.name
        peripheral.delegate = self
        //peripheral.baseDelegate = self
    }
    
    @IBAction func onAnimationSliderValueChange(_ sender: UISlider) {
        peripheral.writeAnimationOnSpeed(Int(sender.value))
    }
    
    @IBAction func onAnimationStepValueChange(_ sender: UIStepper) {
        animationStepLabel.text = String(Int(sender.value))
        peripheral.writeAnimationStep(Int(sender.value))
    }
    
    private func pushColorPicker(_ sender: Any) {
        let vc = ColorPickerViewController()
        vc.delegate = self
        if sender as? NSObject == primaryColorCell {
            vc.pickerColor = currentPrimaryColor
            pickColorFor = ColorSelection.primary
        } else {
            vc.pickerColor = currentSecondaryColor
            pickColorFor = ColorSelection.secodary
        }
        vc.randomColorSupported = randomColorSupport
        vc.randomColorEnabled = currentRandomColor
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private func pushTablePicker(_ dataArray: [Int:String], _ selected: Int, _ title: String) {
        let vc = TablePickerViewController()
        vc.title = title
        vc.delegate = self
        vc.dataArray = (dataArray, selected)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setColorIndication(for indicator: UIView, with color: UIColor) {
        indicator.backgroundColor = UIColor.dynamicColor(
            light: color.withAlphaComponent(0.7),
            dark: color.withAlphaComponent(0.5))
    }
    
    private func setAnimationUI(for animation: Int) {
        hidingCells.removeAll()
        hidingSections = nil
        animationCell.detailTextLabel?.text = TorchereData.animationModes[animation]?.localized
        switch animation {
        case 1:
            print("Animation - Tetris")
            hidingCells.append(tableView.indexPath(for: stepCell)!)
            randomColorSupport = true
            break
        case 2:
            print("Animation - Wave")
            randomColorSupport = false
            break
        case 3:
            print("Animation - Transfusion")
            hidingCells.append(tableView.indexPath(for: stepCell)!)
            hidingCells.append(tableView.indexPath(for: directionCell)!)
            randomColorSupport = true
            break
        case 4:
            print("Animation - Rainbow Transfusion")
            hidingCells.append(tableView.indexPath(for: stepCell)!)
            hidingCells.append(tableView.indexPath(for: directionCell)!)
            hidingCells.append(tableView.indexPath(for: secondaryColorCell)!)
            hidingCells.append(tableView.indexPath(for: primaryColorCell)!)
            hidingSections = 0
            randomColorSupport = false
            break
        case 5:
            print("Animation - Rainbow")
            hidingCells.append(tableView.indexPath(for: stepCell)!)
            randomColorSupport = false
            break
        case 6:
            print("Animation - Static")
            hidingCells.append(tableView.indexPath(for: stepCell)!)
            hidingCells.append(tableView.indexPath(for: speedCell)!)
            hidingCells.append(tableView.indexPath(for: directionCell)!)
            hidingCells.append(tableView.indexPath(for: secondaryColorCell)!)
            randomColorSupport = false
            break
        default:
            print("Unknown animation selection")
        }
        //tableView.reloadData()
        print("Hidden cell \(hidingCells)")
    }
    
    private func showAlert() {
        print("SHOWING ALERT")
        self.present(alert, animated: false, completion: nil)
    }
    
    private func hideAlert() {
        print("HIDING ALERT")
        alert.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - ColorPicker Delegate
    
    func getColor(color: UIColor) {
        if pickColorFor == ColorSelection.primary {
            currentPrimaryColor = color
            setColorIndication(for: primaryColorCell, with: color)
            peripheral.writePrimaryColor(color)
        } else if pickColorFor == ColorSelection.secodary {
            currentSecondaryColor = color
            setColorIndication(for: secondaryColorCell, with: color)
            peripheral.writeSecondaryColor(color)
        }
    }
    
    func randomColor(enabled: Bool) {
        currentRandomColor = enabled
        peripheral.writeRandomColor(enabled)
    }
    
    // MARK: - TablePicker Delegate
    
    func getSelection(at index: Int, in array: [Int : String]) {
        switch array {
        case TorchereData.animationModes:
            currentAnimation = index
            //animationCell.detailTextLabel?.text = array[index]
            peripheral.writeAnimationMode(index)
            setAnimationUI(for: index)
            break
        case TorchereData.animationDirection:
            currentAnimationDirection = index
            directionCell.detailTextLabel?.text = array[index]?.localized
            peripheral.writeAnimationDirection(index)
            break
        default:
            print("Unknown selection at \(array) - \(index)")
        }
    }
    
    // MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.cellForRow(at: indexPath) {
        case primaryColorCell:
            print("Primary color cell")
            pushColorPicker(primaryColorCell!)
            break
        case secondaryColorCell:
            print("Secondary color cell")
            pushColorPicker(secondaryColorCell!)
            break
        case animationCell:
            print("Animation cell")
            pushTablePicker(TorchereData.animationModes, currentAnimation ?? 1, "Animation".localized)
            break
        case directionCell:
            print("Direction cell")
            pushTablePicker(TorchereData.animationDirection, currentAnimationDirection ?? 1, "Direction".localized)
            break
        default:
            print("Unknown cell at \(indexPath)")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard ((hidingCells.contains(indexPath as IndexPath))) else {
            return 44
        }
        print("Hiding cell")
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard hidingSections != nil else {
            return UITableView.automaticDimension
        }
        return 0
    }
    
    // MARK: - Peripheral Delegate
    
    func peripheralDidConnect() {
        print("ZConnected to \(peripheral.name ?? "Device")")
        hideAlert()
    }
    
    func peripheralDidDisconnect() {
        print("Disconnected from \(peripheral.name ?? "Device")")
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func peripheralIsReady() {
        //
    }
    
    func peripheralFirmwareVersion(_ version: Int) {
        print("Firmware version \(version)")
    }
    
    func peripheralOnDFUMode() {
        #warning("TODO: Handle peripheral DFU mode state")
    }

}

