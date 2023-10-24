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
        default:
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
        
        let savedOption = UserDefaults.custom.integer(forKey: SDKConstants.KEY_CONFIG)
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
        let type = selectedConfigOption!
        
        var config: FTRConfig
        if UserDefaults(suiteName: SDKConstants.APP_GROUP)?.bool(forKey: SDKConstants.APP_GROUP_ENABLED) == true {
            config = FTRConfig(sdkId: SDKConstants.SDKID,
                                   sdkKey: SDKConstants.SDKKEY,
                                   baseUrl: SDKConstants.SDKURL,
                                   keychain: FTRKeychainConfig(accessGroup: SDKConstants.KEYCHAIN_ACCESS_GROUP),
                                   lockConfiguration: LockConfiguration(type: type,
                                                                        unlockDuration: 60,
                                                                        invalidatedByBiometricsChange: true)
                                   ,appGroup: SDKConstants.APP_GROUP
            )
        } else {
            config = FTRConfig(sdkId: SDKConstants.SDKID,
                                   sdkKey: SDKConstants.SDKKEY,
                                   baseUrl: SDKConstants.SDKURL,
                                   lockConfiguration: LockConfiguration(type: type,
                                                                        unlockDuration: 60,
                                                                        invalidatedByBiometricsChange: true)
            )
        }
        
        FTRClient.launch(with: config) { [unowned self] in
            
            setupSdkView()
            
            if let token = UserDefaults.custom.data(forKey: SDKConstants.DEVICE_TOKEN_KEY) {
                FTRClient.shared()?.registerPushToken(token)
            }
        } failure: { [unowned self] error in
            print(error)
            valueTextView.text = (error as NSError).userInfo["msg"] as? String ?? error.localizedDescription
        }
    }
    
    func setupSdkView(){
        sdkClient = FTRClient.shared()
//        sdkClient?.setUserPresenceDelegate(self)
        if(UserDefaults.custom.bool(forKey: SDKConstants.ADAPTIVE_ENABLED_KEY)){
            if let vc = (tabBarController?.viewControllers?.first { $0 is ViewController }){
                sdkClient?.enableAdaptive(with: vc as! FTRAdaptiveSDKDelegate)
            }
        }
        valueTextView.text = "SDK is launched with config: \(nameForOption(selectedConfigOption!))"
        setupButtonsForOption(selectedConfigOption!)
        if let index = (options.firstIndex { $0 == selectedConfigOption }){
            settingsPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        checkBiometricsBtn.isHidden = selectedConfigOption! == .none
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
            if let status = sdkClient?.getSdkState(), let types = sdkClient?.getActiveUnlockMethods() {
                let unlockTypes = types.map { nameForUnlockType($0.intValue) }.joined(separator: ", ")
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
        
        UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                  forKey: SDKConstants.KEY_CONFIG)
        
        setupConfig()
    }
    
    @IBAction func launchWithAppGroup(_ sender: Any) {
        UserDefaults.custom.set(true, forKey: SDKConstants.APP_GROUP_ENABLED)
        saveSettings(sender)
    }
    
    @IBAction func reset(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        FTRClient.reset()
        UserDefaults.custom.set(0,
                                  forKey: SDKConstants.KEY_CONFIG)
        selectedConfigOption = nil;
        [pinStack, unlockWithBiometricsBtn, unlockWithBiometricsPasscodeBtn, lockSDKBtn, checkBiometricsBtn].forEach { $0?.isHidden = true }
        statusLabel.text = ""
        valueTextView.isHidden = false
        valueTextView.text = "SDK is not launched\nSelect lock configuration and press launch button below"
    }
    
    @IBAction func switchConfig(_ sender: Any) {
        let row = settingsPickerView.selectedRow(inComponent: 0)
        selectedConfigOption = options[row]
        
        if(selectedConfigOption! == .sdkPinWithBiometricsOptional) {
            let vc = PinViewController.create(pinMode: .input, title: "SWITCH TO PIN") { [unowned self] pin in
                if let pin = pin {
                    sdkClient?.switch(toLockConfigurationSDKPin: LockConfiguration(type: selectedConfigOption!,
                                                                                   unlockDuration: 60,
                                                                                   invalidatedByBiometricsChange: true), sdkPin: pin, callback: { [unowned self] error in
                        valueTextView.isHidden = false
                        valueTextView.text = ((error == nil ? "Success" : (error! as NSError).userInfo["msg"] as? String ?? error?.localizedDescription) ?? "Error")
                        
                        if(error == nil){
                            UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                                      forKey: SDKConstants.KEY_CONFIG)
                            setupSdkView()
                        }
                    })
                    
                }
            }
            
            present(vc, animated: true)
        } else if(selectedConfigOption! == .biometricsOnly) {
            sdkClient?.switch(toLockConfigurationBiometrics: LockConfiguration(type: selectedConfigOption!,
                                                                               unlockDuration: 60,
                                                                               invalidatedByBiometricsChange: true), promptReason: "Unlock to switch configuration", callback: { [unowned self] error in
                valueTextView.isHidden = false
                valueTextView.text = ((error == nil ? "Success" : (error! as NSError).userInfo["msg"] as? String ?? error?.localizedDescription) ?? "Error")
                
                if(error == nil){
                    UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                              forKey: SDKConstants.KEY_CONFIG)
                    setupSdkView()
                }
            })
        } else if(selectedConfigOption! == .biometricsOrPasscode) {
            sdkClient?.switch(toLockConfigurationBiometricsOrPasscode: LockConfiguration(type: selectedConfigOption!,
                                                                                         unlockDuration: 60,
                                                                                         invalidatedByBiometricsChange: true), promptReason: "Unlock to switch configuration", callback: { [unowned self] error in
                valueTextView.isHidden = false
                valueTextView.text = ((error == nil ? "Success" : (error! as NSError).userInfo["msg"] as? String ?? error?.localizedDescription) ?? "Error")
                
                if(error == nil){
                    UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                              forKey: SDKConstants.KEY_CONFIG)
                    setupSdkView()
                }
            })
        } else {
            sdkClient?.switch(toLockConfigurationNone: LockConfiguration(type: selectedConfigOption!,
                                                                         unlockDuration: 60,
                                                                         invalidatedByBiometricsChange: true), callback: { [unowned self] error in
                valueTextView.isHidden = false
                valueTextView.text = ((error == nil ? "Success" : (error! as NSError).userInfo["msg"] as? String ?? error?.localizedDescription) ?? "Error")
                
                if(error == nil){
                    UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                              forKey: SDKConstants.KEY_CONFIG)
                    setupSdkView()
                }
            })
        }
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
    
    @IBAction func checkBiometricsPermission(_ sender: Any) {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Request permission") { [unowned self] granted, error in
            DispatchQueue.main.async { [unowned self] in
                valueTextView.text = "Last operation: " + (granted ? "Permission granted" : (error?.localizedDescription ?? "Permission not granted"))
                valueTextView.isHidden = false
            }
        }
    }
    
    @IBAction func clearLaunchConfigDefault(_ sender: Any) {
        UserDefaults.custom.removeObject(forKey: SDKConstants.KEY_CONFIG)
        valueTextView.isHidden = false
        valueTextView.text = "Launch config option cleared"
    }
    
    @IBAction func checkAppGroupDataExists(_ sender: Any) {
        let row = settingsPickerView.selectedRow(inComponent: 0)
        selectedConfigOption = options[row]
        let dataExists = FTRClient.checkDataExists(forAppGroup: SDKConstants.APP_GROUP,
                                                   keychainConfig: FTRKeychainConfig(accessGroup: SDKConstants.APP_GROUP),
                                                   lockConfiguration: .init(type: selectedConfigOption!,
                                                                            unlockDuration: 60,
                                                                            invalidatedByBiometricsChange: true)
        )
        valueTextView.isHidden = false
        valueTextView.text = dataExists ? "Data exists" : "No data present"
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

extension KeychainConfigViewController: FTRUserPresenceDelegate {
    func userPresenceVerificationType() -> UserPresenceVerificationType {
        .none
    }
}
