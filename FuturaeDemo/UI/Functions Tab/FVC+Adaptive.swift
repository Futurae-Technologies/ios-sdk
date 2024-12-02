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

    @IBAction func toggleAdaptive(_ sender: UIButton) {
        if FTRClient.shared.isAdaptiveEnabled {
            disableAdaptiveCollections()
        } else {
            enableAdaptiveCollections()
        }
    }
    
    func disableAdaptiveCollections(){
        adaptiveAuthButton.isHidden = true
        adaptiveMigrationButton.isHidden = true
        
        FTRClient.shared.disableAdaptiveCollections()
        UserDefaults.custom.set(false, forKey: SDKConstants.ADAPTIVE_COLLECTIONS_ENABLED_KEY)
        adaptiveButton.setTitle("Enable adaptive collections", for: .normal)
    }
    
    func enableAdaptiveCollections(){
        adaptiveAuthButton.isHidden = false
        adaptiveMigrationButton.isHidden = false
        
        FTRClient.shared.enableAdaptiveCollections(delegate: self)
        UserDefaults.custom.set(true, forKey: SDKConstants.ADAPTIVE_COLLECTIONS_ENABLED_KEY)
        adaptiveButton.setTitle("Disable adaptive collections", for: .normal)
    }
    
    @IBAction func toggleAdaptiveAuth(_ sender: UIButton) {
        if FTRClient.shared.isAdaptiveSubmissionOnAuthenticationEnabled {
            disableAdaptiveAuth()
        } else {
            enableAdaptiveAuth()
        }
    }
    
    func disableAdaptiveAuth(){
        FTRClient.shared.disableAdaptiveSubmissionOnAuthentication()
        UserDefaults.custom.set(false, forKey: SDKConstants.ADAPTIVE_ENABLED_AUTH_KEY)
        adaptiveAuthButton.setTitle("Enable adaptive authentication", for: .normal)
    }
    
    func enableAdaptiveAuth(){
        try? FTRClient.shared.enableAdaptiveSubmissionOnAuthentication()
        UserDefaults.custom.set(true, forKey: SDKConstants.ADAPTIVE_ENABLED_AUTH_KEY)
        adaptiveAuthButton.setTitle("Disable adaptive authentication", for: .normal)
    }
    
    @IBAction func toggleAdaptiveMigration(_ sender: UIButton) {
        if FTRClient.shared.isAdaptiveSubmissionMigrationEnabled {
            disableAdaptiveMigration()
        } else {
            enableAdaptiveMigration()
        }
    }
    
    func disableAdaptiveMigration(){
        FTRClient.shared.disableAdaptiveSubmissionOnAccountMigration()
        UserDefaults.custom.set(false, forKey: SDKConstants.ADAPTIVE_ENABLED_MIGRATION_KEY)
        adaptiveMigrationButton.setTitle("Enable adaptive migration", for: .normal)
    }
    
    func enableAdaptiveMigration(){
        try? FTRClient.shared.enableAdaptiveSubmissionOnAccountMigration()
        UserDefaults.custom.set(true, forKey: SDKConstants.ADAPTIVE_ENABLED_MIGRATION_KEY)
        adaptiveMigrationButton.setTitle("Disable adaptive migration", for: .normal)
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
