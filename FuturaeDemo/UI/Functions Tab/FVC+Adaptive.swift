//
//  FVC+Adaptive.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

extension FunctionsViewController {
    @IBAction func adaptiveCollections(_ sender: UIButton) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AdaptiveViewController") as? AdaptiveViewController {
            present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func enableAdaptive(_ sender: UIButton) {
        FTRClient.shared.enableAdaptive(delegate: self)
        UserDefaults.custom.set(true, forKey: SDKConstants.ADAPTIVE_ENABLED_KEY)
        enableAdaptiveButton.isHidden = true
        disableAdaptiveButton.isHidden = false
        UserDefaults.standard.set(true, forKey: "adaptive_enabled")
    }

    @IBAction func disableAdaptive(_ sender: UIButton) {
        FTRClient.shared.disableAdaptive()
        UserDefaults.custom.set(false, forKey: SDKConstants.ADAPTIVE_ENABLED_KEY)
        enableAdaptiveButton.isHidden = false
        disableAdaptiveButton.isHidden = true
        UserDefaults.standard.set(false, forKey: "adaptive_enabled")
    }
}

extension FunctionsViewController: FTRAdaptiveSDKDelegate {
    func bluetoothSettingStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func bluetoothPermissionStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationSettingStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationPermissionStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func locationPrecisePermissionStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func networkSettingStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func networkPermissionStatus() -> FuturaeKit.FTRAdaptivePermissionStatus {
        .on
    }
    
    func didReceiveUpdate(withCollectedData collectedData: [String : Any]) {
        AdaptiveDebugStorage.shared().save(collectedData)
    }
}
