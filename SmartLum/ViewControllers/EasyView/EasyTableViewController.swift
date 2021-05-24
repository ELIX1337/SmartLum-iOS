//
//  ParentTableViewController.swift
//  SmartLum
//
//  Created by Tim on 20/11/2020.
//  Copyright © 2021 SmartLum. All rights reserved.
//

import UIKit
import iOSDFULibrary

class EasyTableViewController: UITableViewController,
                                 UIPopoverPresentationControllerDelegate,
                                 EasyBaseDelegate,
                                 EasyExtendedDelegate,
                                 ColorDelegate,
                                 TablePickerDelegate,
                                 EasyInfoDelegate {
    
    @IBOutlet weak var showColorPickerButton: UIButton!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var animationCell: UITableViewCell!
    @IBOutlet weak var animationOnSpeedSlider: UISlider!
    @IBOutlet weak var animationOffSpeedSlider: UISlider!
    @IBOutlet weak var randomColorModeCell: UITableViewCell!
    @IBOutlet weak var adaptiveBrightnessSwitch: UISwitch!
    @IBOutlet weak var dayNightModeCell: UITableViewCell!
    private var loadingAlert: UIAlertController?
    
    private var peripheral:EasyPeripheral!
    private var currentColor:UIColor? = UIColor.white
    private var trueColor:UIColor?    = UIColor.white
    private var brightness:Float?     = 1.0
    
    var currentAnimation:Int?
    var currentRandomColorMode:Int?
    var currentDayNightMode:Int?
    var randomColorModeState:Bool?
    
    var stripType:EasyData.stripType?
    var stepsCount:Int?
    var topSensorTriggerDistance:Int?
    var botSensorTriggerDistance:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //showLoadingView()
        peripheral.connect()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            peripheral.disconnect()
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.none
    }
    
    public func setPeripheral(_ peripheral: EasyPeripheral) {
        self.peripheral = peripheral
        title = peripheral.advertisedName
        peripheral.baseDelegate = self
        peripheral.extendedDelegate = self
    }
    
    private func showLoadingView() {
        loadingAlert = UIAlertController(title: nil,
                                      message: "Connecting...",
                                      preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            loadingIndicator.style = UIActivityIndicatorView.Style.medium
        } else {
            loadingIndicator.style = UIActivityIndicatorView.Style.white
        }
        loadingIndicator.startAnimating();
        loadingAlert?.view.addSubview(loadingIndicator)
        present(loadingAlert!, animated: true, completion: nil)
    }
    
    private func hideLoadingView() {
        loadingAlert?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onBrightnessSliderValueChange(sender: UISlider) {
        writeBrightness(value: sender.value)
    }
    
    @IBAction func switchAdaptiveBrightnessMode(_ sender: UISwitch) {
        peripheral.setAdaptiveBrightnessMode(mode: sender.isOn)
    }
    
    @IBAction func onAnimationSpeedSlidersValueChange(sender: UISlider) {
        if sender == animationOnSpeedSlider {
            peripheral.setAnimationOnSpeed(speed: Int(sender.value))
        } else if sender == animationOffSpeedSlider {
            peripheral.setAnimationOffSpeed(speed: Int(sender.value))
        }
    }
    
    @IBAction func pushColorPicker(sender: Any) {
        let vc = ColorPickerViewController()
        vc.delegate = self
        vc.pickerColor = currentColor
        self.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    private func pushTablePicker(_ sender: Any, _ dataArray: [Int:String], _ selected: Int?) {
        let vc = TablePickerViewController()
        vc.delegate = self
        vc.dataArray = (dataArray, selected)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PushEasyInfo" {
            let easyInfoView = segue.destination as! EasyInfoViewController
            easyInfoView.delegate = self
            easyInfoView.stripType = self.stripType
            easyInfoView.numberOfSteps = self.stepsCount
            easyInfoView.topSensorTriggerDistance = self.topSensorTriggerDistance
            easyInfoView.botSensorTriggerDistance = self.botSensorTriggerDistance
        }
    }
    
    func calculateColorBrightness(_ color: UIColor) -> Float {
        let colors = [color.rgb()!.red, color.rgb()!.green, color.rgb()!.blue]
        return colors.max()!
    }
    
    func getFullBrightnessColor(_ color: UIColor) -> UIColor {
        if brightness != 0.0 {
            let maxRed = color.rgb()!.red * (1 / brightness!)
            let maxGreen = color.rgb()!.green * (1 / brightness!)
            let maxBlue = color.rgb()!.blue * (1 / brightness!)
            return UIColor(red: CGFloat(maxRed), green: CGFloat(maxGreen), blue: CGFloat(maxBlue), alpha: 1.0)
        } else {
            return UIColor(red: CGFloat(1), green: CGFloat(1), blue: CGFloat(1), alpha: 1.0)
        }

    }
    
    func writeBrightness(value: Float) {
        if var color = currentColor {
            color = UIColor(
                red:   CGFloat(trueColor!.rgb()!.red   * value),
                green: CGFloat(trueColor!.rgb()!.green * value),
                blue:  CGFloat(trueColor!.rgb()!.blue  * value),
                alpha: 1.0)
            currentColor = color
            peripheral.setColor(color: color)
            setSliderValue(color: color, value: false)
        }
    }
    
    func setSliderValue(color: UIColor, value: Bool) {
        brightnessSlider.minimumTrackTintColor = color
        if value {
            brightnessSlider.setValue(brightness!, animated: true)
        }
    }
    
    // MARK: - ColorPicker Protocol Delegate
    
    func getColor(color: UIColor) {
        peripheral.setColor(color: color)
        if color != UIColor.black {
            currentColor = color
            let colors = [color.rgb()!.red, color.rgb()!.green, color.rgb()!.blue]
            brightness = colors.max()!
            trueColor  = getFullBrightnessColor(color)
            setSliderValue(color: color, value: true)
        } else {
            brightnessSlider.setValue(0, animated: true)
        }
    }
    
    // MARK: - Table Selection Protocol Delegate
    
    func getSelection(at index: Int, in array: [Int:String]) {
        switch array {
        case EasyData.animationModes:
            currentAnimation = index
            animationCell.detailTextLabel?.text = array[index]
            peripheral.setAnimationMode(mode: index)
            break
        case EasyData.randomColorModes:
            currentRandomColorMode = index
            randomColorModeCell.detailTextLabel?.text = array[index]
            peripheral.setRandomColorMode(mode: index)
            break
        case EasyData.dayNightModes:
            currentDayNightMode = index
            dayNightModeCell.detailTextLabel?.text = array[index]
            peripheral.setDayNightMode(mode: index)
        default:
            print("Unknown selection in array \(array) with index \(index) ")
        }
        print("SELECTED INDEX: \(index)")
        tableView.reloadData()
    }
    
    // MARK: - Easy Info Delegate
    
    func getStripType(type: EasyData.stripType) {
        peripheral.setStripType(type: type)
        showColorPickerButton.isEnabled = type == EasyData.stripType.RGB
        self.stripType = type
    }
    
    func resetDevice() {
        peripheral.resetPeripheral()
    }
    
    func updateDeviceFirmware() {
        let firmwareUpdateController = FirmwareUpdateViewController()
        firmwareUpdateController.peripheralUUID = EasyPeripheral.UART_serviceUUID
        navigationController?.present(firmwareUpdateController, animated: true, completion: nil)
    }

    // MARK: - Peripheral Protocol Delegate
    
    func peripheralDidConnect(RGBSupported: Bool) {
        print("Connected to device")
    }
    
    func peripheralDidDisconnect() {
        print("Disconnected from device")
        hideLoadingView()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func peripheralIsReady(isReady: Bool) {
        peripheral.requestPeripheralSettings()
    }
    
    func peripheralConfigured(_ isConfigured: Bool) {
        if !isConfigured {
            loadingAlert?.dismiss(animated: true, completion: {

            })
            let vc = EasySetupViewController()
            //vc.peripheral = self.peripheral
            vc.setPeripheral(peripheral)
            self.navigationController?.present(vc, animated: true, completion: nil)
        }
    }
    
    func peripheralSettingsReceived(_ isReceived: Bool) {
        hideLoadingView()
        print("SETTINGS RECEIVED \(isReceived)")
    }
    
    func peripheralError(_ register: Int, _ code: Int) {
        //
    }
    
    func peripheralLEDColor(_ color: UIColor) {
        currentColor = color
        brightness = calculateColorBrightness(color)
        trueColor = getFullBrightnessColor(color)
        setSliderValue(color: color, value: true)
    }
    
    func peripheralAnimationMode(_ mode: Int) {
        currentAnimation = mode
        animationCell.detailTextLabel?.text = EasyData.animationModes[mode]
    }
    
    func peripheralAnimationOnSpeed(_ speed: Int) {
        animationOnSpeedSlider.setValue(Float(speed), animated: true)
    }
    
    func peripheralAnimationOffSpeed(_ speed: Int) {
        animationOffSpeedSlider.setValue(Float(speed), animated: true)
    }
    
    func peripheralAdaptiveBrightnessMode(_ state: Bool) {
        adaptiveBrightnessSwitch.setOn(state, animated: true)
    }
    
    func peripheralDayNightModeOnTime(_ time: Int) {
        
    }
    
    func peripheralDayNightModeOffTime(_ time: Int) {
        
    }
    
    func peripheralStepsCount(_ count: Int) {
        stepsCount = count
    }
    
    func peripheralBotSensorTriggerDistance(_ distance: Int) {
        print("Easy view bot trigger - \(distance)")
        botSensorTriggerDistance = distance
    }
    
    func peripheralTopSensorTriggerDistance(_ distance: Int) {
        print("Easy view top trigger - \(distance)")
        topSensorTriggerDistance = distance
    }
    
    func peripheralRandomColorMode(_ mode: Int) {
        currentRandomColorMode = mode
        randomColorModeCell.detailTextLabel?.text = EasyData.randomColorModes[mode]
    }
    
    func peripheralDayNightMode(_ mode: Int) {
        currentDayNightMode = mode
        dayNightModeCell.detailTextLabel?.text = EasyData.dayNightModes[mode]
    }
    
    func peripheralStripType(_ type: EasyData.stripType) {
        showColorPickerButton.isEnabled = type == EasyData.stripType.RGB
        stripType = type
    }
        
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch tableView.cellForRow(at: indexPath) {
            case animationCell:
                pushTablePicker(animationCell!, EasyData.animationModes, currentAnimation)
                break
            case randomColorModeCell:
                pushTablePicker(randomColorModeCell!, EasyData.randomColorModes, currentRandomColorMode)
                break
            case dayNightModeCell:
                pushTablePicker(dayNightModeCell!, EasyData.dayNightModes, currentDayNightMode)
            default:
                print("Unknown cell")
        }
    }
    
}
