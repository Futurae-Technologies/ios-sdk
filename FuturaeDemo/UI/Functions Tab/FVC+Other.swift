//
//  FVC+Other.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

extension FunctionsViewController {
    @IBAction func validateAttestation(_ sender: UIButton) {
        if #available(iOS 14.0, *) {
            FTRClient.shared.appAttestation(appId: SDKConstants.APP_ID, production: false, success: { [weak self] in
                self?.showAlert(title: "Attestation success", message: "App integrity verified")
            }, failure: { [weak self] error in
                print(error)
                let title = "Attestation success"
                let message = error.localizedDescription
                self?.showAlert(title: title, message: message)
            })
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func jailbreakStatus(_ sender: UIButton) {
        let status = FTRClient.shared.jailbreakStatus
        showAlert(title: status.jailbroken ? "Device is jailbroken" : "Jailbreak not detected", message: status.message ?? "")
    }

    @IBAction func updateAppGroup(_ sender: UIButton) {
        FTRClient.shared.updateSDKConfig(appGroup: SDKConstants.APP_GROUP,
                                         keychainConfig: FTRKeychainConfig(accessGroup: SDKConstants.APP_GROUP),
                                         success: { [weak self] in
            self?.showAlert(title: "App group updated", message: "")
            UserDefaults(suiteName: SDKConstants.APP_GROUP)?.set(true, forKey: "app_group_enabled")
        }, failure: { [weak self] error in
            self?.showAlert(title: "Failed to update", message: error.localizedDescription)
        })
    }

    @IBAction func removeAppGroup(_ sender: UIButton) {
        FTRClient.shared.updateSDKConfig(appGroup: nil, keychainConfig: nil, success: { [weak self] in
            self?.showAlert(title: "App group updated", message: "")
            UserDefaults(suiteName: SDKConstants.APP_GROUP)?.set(false, forKey: "app_group_enabled")
        }, failure: { [weak self] error in
            self?.showAlert(title: "Failed to update", message: error.localizedDescription)
        })
    }
}
