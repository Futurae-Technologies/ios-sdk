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
    
    @IBAction func sessionMethod(_ sender: UIButton) {
        let newValue = !UserDefaults.custom.bool(forKey: SDKConstants.USE_UNPROTECTED_SESSION)
        UserDefaults.custom.set(newValue, forKey: SDKConstants.USE_UNPROTECTED_SESSION)
        
        sessionMethod.setTitle(newValue ? "Use protected session" : "Use unprotected session", for: .normal)
    }
}
