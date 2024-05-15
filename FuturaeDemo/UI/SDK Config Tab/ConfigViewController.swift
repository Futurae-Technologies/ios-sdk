//
//  ConfigViewController.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 12.5.22.
//  Copyright © 2022 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit
import LocalAuthentication

final class ConfigViewController: UIViewController {
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
    
    var unlockFailureHandler: FTRFailureHandler {
        return { error in
            DispatchQueue.main.async { [unowned self] in
                valueTextView.isHidden = false
                valueTextView.text = "Last operation: " + error.localizedDescription
            }
        }
    }
    
    var unlockSuccessHandler: FTRSuccessHandler{
        return {
            DispatchQueue.main.async { [unowned self] in
                valueTextView.isHidden = false
                valueTextView.text = "Last operation: " + "Unlocked"
            }
        }
    }
    
    var timer: Timer?
    
    var selectedConfigOption: LockConfigurationType?
    
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
    
    func nameForUnlockType(_ option: UnlockMethodType) -> String {
        switch option {
        case .biometrics:
            return "Biometrics"
        case .biometricsOrPasscode:
            return "Biometrics OR Passcode"
        case .sdkPin:
            return "SDK PIN"
        default:
            return "Unknown"
        }
    }
    
    var options: [LockConfigurationType] = [.biometricsOrPasscode,
                                                    .biometricsOnly,
                                                    .sdkPinWithBiometricsOptional,
                                                    .none]
    
    var sdkClient: FTRClient?
    
    override func viewDidLoad() {
        FTRClient.setDelegate(self)
        
        super.viewDidLoad()
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().tintColor = .green
        UITabBar.appearance().unselectedItemTintColor = .gray
        
        let savedOption = UserDefaults.custom.integer(forKey: SDKConstants.KEY_CONFIG)
        if(savedOption > 0) {
            selectedConfigOption = .init(rawValue: savedOption)
            setupConfig()
        } else if(FTRClient.sdkIsLaunched){
            selectedConfigOption = FTRClient.shared.currentLockConfiguration.type
            setupSdkView()
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
        
        do {
            try FTRClient.launch(config: config)
            
            setupSdkView()
            
            if let token = UserDefaults.custom.data(forKey: SDKConstants.DEVICE_TOKEN_KEY) {
                FTRClient.shared.registerPushToken(token, success: {}, failure: { _ in})
            }
        } catch let error {
            valueTextView.text = error.localizedDescription
        }
    }
    
    func setupSdkView(){
        sdkClient = FTRClient.shared
        if(UserDefaults.custom.bool(forKey: SDKConstants.ADAPTIVE_ENABLED_KEY)){
            if let vc = (tabBarController?.viewControllers?.first { $0 is FunctionsViewController }){
                sdkClient?.enableAdaptive(delegate: vc as! FTRAdaptiveSDKDelegate)
            }
        }
        
        setupButtonsForOption(selectedConfigOption!)
        if let index = (options.firstIndex { $0 == selectedConfigOption }){
            settingsPickerView.selectRow(index, inComponent: 0, animated: false)
        }
        
        checkBiometricsBtn.isHidden = selectedConfigOption! == .none
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
            if let status = sdkClient?.sdkState, let types = sdkClient?.activeUnlockMethods {
                let unlockTypes = types.map { nameForUnlockType($0) }.joined(separator: ", ")
                statusLabel.text = "STATUS: \(stringForEnum(status.lockStatus)) \nUNLOCK SECONDS LEFT: \(Int(status.unlockedRemainingDuration.rounded()))\nUNLOCK METHODS: \(unlockTypes)"
            }
        }
        
        if let accounts = try? sdkClient?.getAccounts(), accounts.count > 0 {
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
    }
    
    @IBAction func saveSettings(_ sender: Any) {
        let row = settingsPickerView.selectedRow(inComponent: 0)
        selectedConfigOption = options[row]
        
        UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                  forKey: SDKConstants.KEY_CONFIG)
        
        setupConfig()
    }
    
    @IBAction func reset(_ sender: Any) {
        timer?.invalidate()
        timer = nil
        FTRClient.reset(appGroup: UserDefaults(suiteName: SDKConstants.APP_GROUP)?
            .bool(forKey: "app_group_enabled") == true ? SDKConstants.KEYCHAIN_ACCESS_GROUP : nil)
        UserDefaults.custom.set(0,
                                  forKey: SDKConstants.KEY_CONFIG)
        
        UserDefaults.custom.setValue(false, forKey: SDKConstants.ADAPTIVE_ENABLED_KEY)
        selectedConfigOption = nil;
        [pinStack, unlockWithBiometricsBtn, unlockWithBiometricsPasscodeBtn, lockSDKBtn, checkBiometricsBtn].forEach { $0?.isHidden = true }
        statusLabel.text = ""
    }
    
    @IBAction func switchConfig(_ sender: Any) {
        let row = settingsPickerView.selectedRow(inComponent: 0)
        selectedConfigOption = options[row]
        let lockConfig = LockConfiguration(type: selectedConfigOption!,
                                           unlockDuration: 60,
                                          invalidatedByBiometricsChange: true)
        let successCallback: FTRSuccessHandler = { [unowned self] in
            valueTextView.isHidden = false
            valueTextView.text = "Last operation: " + "Success"
            
            UserDefaults.custom.set(selectedConfigOption?.rawValue ?? 0,
                                      forKey: SDKConstants.KEY_CONFIG)
            setupSdkView()
        }
        
        let failureCallback: FTRFailureHandler = { [unowned self] error in
            valueTextView.isHidden = false
            valueTextView.text = "Last operation: " + error.localizedDescription
        }
        
        if(selectedConfigOption! == .sdkPinWithBiometricsOptional) {
            let vc = PinViewController.create(pinMode: .input, title: "SWITCH TO PIN") { [unowned self] pin in
                if let pin = pin {
                    sdkClient?.switchToLockConfiguration(.with(sdkPin: pin, newLockConfiguration: lockConfig),
                                                         success: successCallback,
                                                         failure: failureCallback)
                }
            }
            
            present(vc, animated: true)
        } else if(selectedConfigOption! == .biometricsOnly) {
            sdkClient?.switchToLockConfiguration(.with(biometricsPrompt: "Unlock to switch configuration",
                                                       newLockConfiguration: lockConfig),
                                                 success: successCallback,
                                                 failure: failureCallback)
        } else if(selectedConfigOption! == .biometricsOrPasscode) {
            sdkClient?.switchToLockConfiguration(.with(biometricsOrPasscodePrompt: "Unlock to switch configuration",
                                                       newLockConfiguration: lockConfig),
                                                 success: successCallback,
                                                 failure: failureCallback)
        } else {
            sdkClient?.switchToLockConfiguration(.with(newLockConfiguration: lockConfig),
                                                 success: successCallback,
                                                 failure: failureCallback)
        }
    }
    
    @IBAction func lockSDK(_ sender: Any) {
        
        do {
            try sdkClient?.lock()
            valueTextView.text = "Last operation: " + "Locked"
        } catch {
            valueTextView.text = "Last operation: " + error.localizedDescription
        }
        
        valueTextView.isHidden = false
    }
    
    // UNLOCK
    @IBAction func unlockWithBiometrics(_ sender: Any) {
        // AsyncTask example with `Result` callback
        sdkClient?.unlock(.with(biometricsPrompt: "Unlock SDK")).execute({ [unowned self] in
            switch $0 {
            case .success:
                unlockSuccessHandler()
            case .failure(let error):
                unlockFailureHandler(error)
            }
        })
        
        
        // AsyncTask with RxSwift example
//        sdkClient?.unlock(.with(biometricsPrompt: "Unlock SDK"))
//            .rx
//            .subscribe(onCompleted: { [unowned self] in
//                unlockSuccessHandler()
//            }, onError: { [unowned self] error in
//                unlockFailureHandler(error)
//            }).disposed(by: disposedBag)
        
        // AsyncTask with Combine example
//        sdkClient?.unlock(.with(biometricsPrompt: "Unlock SDK"))
//            .publisher
//            .sink(receiveCompletion: { [unowned self] completion in
//                switch completion {
//                case .finished:
//                    unlockSuccessHandler()
//                case .failure(let error):
//                    unlockFailureHandler(error)
//                }
//            }, receiveValue: { _ in }).store(in: &cancellables)
    }
    
    @IBAction func unlockWithBiometricsPasscode(_ sender: Any) {
        sdkClient?.unlock(.with(biometricsOrPasscodePrompt: "Unlock SDK"), success: unlockSuccessHandler, failure: unlockFailureHandler)
    }
    
    // PIN
    @IBAction func unlockWithPin(_ sender: Any) {
        let vc = PinViewController.create(pinMode: .input, title: "UNLOCK WITH PIN") { [unowned self] pin in
            if let pin = pin {
                sdkClient?.unlock(.with(sdkPin: pin), success: unlockSuccessHandler, failure: unlockFailureHandler)
            }
        }
        
        present(vc, animated: true)
    }
    
    @IBAction func changePin(_ sender: Any) {
        let vc = PinViewController.create(pinMode: .input, title: "CHANGE PIN") { [unowned self] pin in
            if let pin = pin {
                sdkClient?.changeSDKPin(newSDKPin: pin, success: {
                    DispatchQueue.main.async { [unowned self] in
                        valueTextView.isHidden = false
                        valueTextView.text = "Last operation: " + "Pin changed"
                    }
                }, failure: { error in
                    DispatchQueue.main.async { [unowned self] in
                        valueTextView.isHidden = false
                        valueTextView.text = "Last operation: " + error.localizedDescription
                    }
                })
            }
        }
        
        present(vc, animated: true)
    }
    
    
    @IBAction func activateBiometrics(_ sender: Any) {
        do {
            try sdkClient?.activateBiometrics()
            valueTextView.text = "Last operation: " + "Biometrics for pin is activated"
        } catch {
            valueTextView.text = "Last operation: " + error.localizedDescription
        }
        
        valueTextView.isHidden = false
    }
    
    @IBAction func deactivateBiometrics(_ sender: Any) {
        do {
            try sdkClient?.deactivateBiometrics()
            valueTextView.text = "Last operation: " + "Biometrics for pin is deactivated"
        } catch {
            valueTextView.text = "Last operation: " + error.localizedDescription
        }
        
        valueTextView.isHidden = false
    }
    
    @IBAction func checkBiometricsValidity(_ sender: Any) {
        let haveBiometricsChanged = sdkClient?.haveBiometricsChanged ?? false
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
    
    @IBAction func launchWithAppGroup(_ sender: Any) {
        UserDefaults.custom.set(true, forKey: SDKConstants.APP_GROUP_ENABLED)
        saveSettings(sender)
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

extension ConfigViewController: FTRClientDelegate {
    func didUpdateStatus(status: SDKStatus) {
        var message = ""
        
        switch status {
        case .notLaunched:
            message = "SDK is not launched\nSelect lock configuration and press launch button below"
        case .launched:
            message = "SDK is launched with config: \(nameForOption(selectedConfigOption!))"
        case .launching:
            message = "SDK is currently launching"
        case .needsReset:
            message = "SDK needs to be reset"
        }
        
        valueTextView.isHidden = false
        valueTextView.text = message
    }
}

extension ConfigViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {}
}

extension ConfigViewController: UIPickerViewDataSource {
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
