//
//  KeychainConfigViewController.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 12.5.22.
//  Copyright © 2022 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit
import LocalAuthentication

final class KeychainConfigViewController: UIViewController {
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var valueTextView: UITextView!
    @IBOutlet weak var settingsPickerView: UIPickerView!
    
    // Universal
    @IBOutlet weak var unlockWithBiometricsBtn: UIButton!
    @IBOutlet weak var unlockWithBiometricsPasscodeBtn: UIButton!
    @IBOutlet weak var lockSDKBtn: UIButton!
    @IBOutlet weak var checkBiometricsBtn: UIButton!
    
    //PIN
    @IBOutlet weak var pinStack: UIStackView!
    @IBOutlet weak var unlockWithPIN: UIButton!
    @IBOutlet weak var activatePinBiometricsBtn: UIButton!
    @IBOutlet weak var deactivatePinBiometricsBtn: UIButton!
    @IBOutlet weak var changePinBtn: UIButton!
    
    var timer: Timer?
    
    private var selectedConfigOption: LockConfigurationType?
    
    func nameForOption(_ option: LockConfigurationType) -> String {
        switch(option){
        case .biometricsOnly:
            return "Biometrics only"
        case .biometricsOrPasscode:
            return "Biometrics OR Passcode"
        case .sdkPinWithBiometricsOptional:
            return "Biometrics OR SDK PIN"
        case .none:
            return "None"
        @unknown default:
            return "N/A"
        }
    }
    
    func nameForUnlockType(_ option: Int) -> String {
        guard let option = UnlockMethodType(rawValue: option) else {
            return "None"
        }

        
        switch option {
        case .biometric:
            return "Biometrics"
        case .biometricsOrPasscode:
            return "Biometrics OR Passcode"
        case .sdkPin:
            return "SDK PIN"
        @unknown default:
            return "Unknown"
        }
    }
    
    private var options: [LockConfigurationType] = [.biometricsOrPasscode,
                                                    .biometricsOnly,
                                                    .sdkPinWithBiometricsOptional,
                                                    .none]

    private var sdkClient: FTRClient?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .green
        UITabBar.appearance().unselectedItemTintColor = .gray

        let savedOption = UserDefaults.standard.integer(forKey: "key_config")
        if(savedOption > 0) {
            selectedConfigOption = .init(rawValue: savedOption)
            setupConfig()
        } else if(FTRClient.sdkIsLaunched()){
            selectedConfigOption = LockConfiguration.get()?.type
            setupSdkView()
        } else {
            valueTextView.isHidden = false
            valueTextView.text = "SDK is not launched\nSelect lock configuration and press launch button below"
        }
    }

    func setupConfig(){
        let startInvalidatedByBiometricsChange = LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        let type = selectedConfigOption!
        let config = FTRConfig(sdkId: SDKConstants.SDKID,
                               sdkKey: SDKConstants.SDKKEY,
                               baseUrl: SDKConstants.SDKURL,
                               lockConfiguration: LockConfiguration(type: type,
                                                                    unlockDuration: 60,
                                                                    invalidatedByBiometricsChange: startInvalidatedByBiometricsChange)
        )
        FTRClient.launch(with: config) { [unowned self] in

            setupSdkView()
            
            if let token = UserDefaults.standard.data(forKey: "ftr_device_token") {
                FTRClient.shared()?.registerPushToken(token)
            }
        } failure: { [unowned self] error in
            print(error)
            valueTextView.text = (error as NSError).userInfo["msg"] as? String ?? error.localizedDescription
        }
    }
    
    func setupSdkView(){
        sdkClient = FTRClient.shared()
        valueTextView.text = "SDK is launched with config: \(nameForOption(selectedConfigOption!))"
        setupButtonsForOption(selectedConfigOption!)
        if let index = (options.firstIndex { $0 == selectedConfigOption }){
            settingsPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
            if let status = sdkClient?.getSdkState(), let types = sdkClient?.getActiveUnlockMethods() {
                let unlockTypes = types.map { nameForUnlockType($0.intValue) }.joined(separator: ", ")
                checkBiometricsBtn.isHidden = !types.contains { $0 == NSNumber(integerLiteral: UnlockMethodType.biometric.rawValue) || $0 == NSNumber(integerLiteral: UnlockMethodType.biometricsOrPasscode.rawValue)}
                statusLabel.text = "STATUS: \(stringForEnum(status.lockStatus)) \nCONFIGURATION: \(stringForEnum(status.configStatus)) \nUNLOCK SECONDS LEFT: \(Int(status.unlockedRemainingDuration.rounded()))\nUNLOCK METHODS: \(unlockTypes)"
            }
        }
        
        if let accounts = sdkClient?.getAccounts(), accounts.count > 0 {
            sdkClient?.getAccountsStatus(accounts, success: { data in
                print("Received accounts status: \(String(describing: data))")
            }, failure: { error in
                print("Could not get accounts status: \(String(describing: error))")
            })
        }
    }
    
    func stringForEnum(_ value: SDKLockStatus) -> String {
        switch(value){
        case .locked:
            return "Locked"
        default:
            return "Unlocked"
        }
    }
    
    func stringForEnum(_ value: SDKLockConfigStatus) -> String {
        switch(value){
        case .valid:
            return "Valid"
        default:
            return "Invalid"
        }
    }
    
    func setupButtonsForOption(_ option: LockConfigurationType){
        switch(option){
        case .none:
            [pinStack, unlockWithBiometricsBtn, unlockWithBiometricsPasscodeBtn, lockSDKBtn].forEach { $0?.isHidden = true }
        case .biometricsOnly:
            [unlockWithBiometricsBtn, lockSDKBtn].forEach { $0?.isHidden = false }
            [pinStack, unlockWithBiometricsPasscodeBtn].forEach { $0?.isHidden = true }
        case .biometricsOrPasscode:
            [unlockWithBiometricsPasscodeBtn, lockSDKBtn].forEach { $0?.isHidden = false }
            [pinStack, unlockWithBiometricsBtn].forEach { $0?.isHidden = true }
        case .sdkPinWithBiometricsOptional:
            [pinStack, unlockWithBiometricsBtn, lockSDKBtn].forEach { $0?.isHidden = false }
            [unlockWithBiometricsPasscodeBtn].forEach { $0?.isHidden = true }
        @unknown default:
            break
        }
        
        statusLabel.isHidden = false
        statusLabel.text = ""
        valueTextView.text = ""
        valueTextView.isHidden = true
    }
    
    
    
    @IBAction func saveSettings(_ sender: Any) {
        let row = settingsPickerView.selectedRow(inComponent: 0)
        selectedConfigOption = options[row]
        
        UserDefaults.standard.set(selectedConfigOption?.rawValue ?? 0,
                                  forKey: "key_config")
        
        setupConfig()
    }
    
    @IBAction func reset(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        FTRClient.reset()
        UserDefaults.standard.set(0,
                                  forKey: "key_config")
        selectedConfigOption = nil;
        [pinStack, unlockWithBiometricsBtn, unlockWithBiometricsPasscodeBtn, lockSDKBtn, checkBiometricsBtn].forEach { $0?.isHidden = true }
        statusLabel.text = ""
        valueTextView.isHidden = false
        valueTextView.text = "SDK is not launched\nSelect lock configuration and press launch button below"
    }
    
    @IBAction func lockSDK(_ sender: Any) {
        let error = sdkClient?.lock()
        valueTextView.isHidden = false
        valueTextView.text = "Last operation: " + (error == nil ? "Locked" : error?.localizedDescription ?? "Error")
    }
    
    // UNLOCK
    @IBAction func unlockWithBiometrics(_ sender: Any) {
        sdkClient?.unlock(biometrics: { error in
            DispatchQueue.main.async { [unowned self] in
                valueTextView.isHidden = false
                valueTextView.text = "Last operation: " + (error == nil ? "Unlocked" : ((error as? NSError)?.userInfo["msg"] as? String ?? "Error"))
            }
        }, promptReason: "Unlock SDK")
    }
    
    @IBAction func unlockWithBiometricsPasscode(_ sender: Any) {
        unlockWithBiometrics(sender)
    }

    // PIN
    @IBAction func unlockWithPin(_ sender: Any) {
        let vc = PinViewController.create(pinMode: .input, title: "UNLOCK WITH PIN") { [unowned self] pin in
            if let pin = pin {
                sdkClient?.unlock(withSDKPin: pin, callback: { [unowned self] error in
                    valueTextView.isHidden = false
                    valueTextView.text = "Last operation: " + (error == nil ? "Unlocked" : ((error as? NSError)?.userInfo["msg"] as? String ?? "Error"))
                })
                
            }
        }

        present(vc, animated: true)
    }
    
    @IBAction func changePin(_ sender: Any) {
        let vc = PinViewController.create(pinMode: .input, title: "CHANGE PIN") { [unowned self] pin in
            if let pin = pin {
                sdkClient?.changeSDKPin(pin, callback: { error in
                    DispatchQueue.main.async { [unowned self] in
                        valueTextView.isHidden = false
                        valueTextView.text = "Last operation: " + (error == nil ? "Pin changed" : ((error as? NSError)?.userInfo["msg"] as? String ?? "Error"))
                    }
                })
            }
        }

        present(vc, animated: true)
    }
    

    @IBAction func activateBiometrics(_ sender: Any) {
        let error = sdkClient?.activateBiometrics()
        valueTextView.isHidden = false
        valueTextView.text = "Last operation: " + (error == nil ? "Biometrics for pin is activated" : ((error as? NSError)?.userInfo["msg"] as? String ?? "Error"))
    }
    
    @IBAction func deactivateBiometrics(_ sender: Any) {
        let error = sdkClient?.deactivateBiometrics()
        valueTextView.isHidden = false
        valueTextView.text = "Last operation: " + (error == nil ? "Biometrics for pin is deactivated" : ((error as? NSError)?.userInfo["msg"] as? String ?? "Error"))
    }
    
    @IBAction func checkBiometricsValidity(_ sender: Any) {
        let haveBiometricsChanged = sdkClient?.haveBiometricsChanged() ?? false
        showAlert(title: "", message: haveBiometricsChanged ? "Biometrics have changed" : "Biometrics have not changed")
    }
}

extension KeychainConfigViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
}

extension KeychainConfigViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        nameForOption(options[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
            return NSAttributedString(string: nameForOption(options[row]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
}
