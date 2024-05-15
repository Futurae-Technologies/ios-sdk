//
//  FunctionsViewController+Approve.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

extension FunctionsViewController {
    @IBAction func syncTokenTouchedUpInside(_ sender: UIButton) {
        do {
            guard let account = try FTRClient.shared.getAccounts().first else {
                self.showAlert(title: "Error", message: "No accounts available.")
                return
            }
            
            let token = try FTRClient.shared.getSynchronousAuthToken(userId: account.userId)
            
            let title = "Sync Auth Token"
            UIPasteboard.general.string = token
            showAlert(title: title, message: token)
        } catch {
            showAlert(title: "Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func totpTouchedUpInside(_ sender: UIButton) {
        totpAuth(sdkPin: nil)
    }
    
    @IBAction func totpWithBiometricsTouchedUpInside(_ sender: Any) {
        operationWithBiometrics = true
        totpAuth(sdkPin: nil)
    }
    
    func showApproveAuthAlertQRCode(_ QRCodeResult: String) {
        guard let userId = FTRUtils.userId(fromQRCode: QRCodeResult),
              let sessionToken = FTRUtils.sessionToken(fromQRCode: QRCodeResult) else {
            self.showAlert(title: "Error", message: "Invalid QR Code")
            return
        }
        
        FTRClient.shared.getSessionInfo(.with(token: sessionToken, userId: userId)) { [weak self] session in
            let extras = session.extraInfo ?? []
            let mutableFormattedExtraInfo = extras.reduce("") { result, extraInfo in
                result + "\(extraInfo.key): \(extraInfo.value)\n"
            }

            let title = "Approve"
            let message = "Request Information\n\(mutableFormattedExtraInfo)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Deny", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { [weak self] _ in
                self?.approveAuthWithQRCode(QRCodeResult, extraInfo: extras)
            }))
            self?.present(alert, animated: true, completion: nil)
        } failure: { error in
            print(error)
            
            self.dismiss(animated: true) {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func approveAuthWithQRCode(_ QRCodeResult: String, extraInfo: [FTRExtraInfo]?) {
        FTRClient.shared.replyAuth(AuthReplyParameters.approveQRCode(QRCodeResult, extraInfo: extraInfo), success: {
            self.dismiss(animated: true) {
                self.showAlert(title: "Success", message: "User authenticated successfully!")
            }
        }, failure: { error in
            self.dismiss(animated: true) {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        })
    }

    func showApproveAuthAlertUsernamelessQRCode(_ QRCodeResult: String) {
        let userId = try! FTRClient.shared.getAccounts().first!.userId
        guard let sessionToken = FTRUtils.sessionToken(fromQRCode: QRCodeResult) else {
            self.showAlert(title: "Error", message: "Invalid QR Code")
            return
        }
        
        FTRClient.shared.getSessionInfo(.with(token: sessionToken, userId: userId)) { [weak self] session in
            let extras = session.extraInfo ?? []
            let mutableFormattedExtraInfo = extras.reduce("") { result, extraInfo in
                result + "\(extraInfo.key): \(extraInfo.value)\n"
            }

            let title = "Approve"
            let message = "Request Information\n\(mutableFormattedExtraInfo)"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Deny", style: .destructive, handler: nil))
            alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { [weak self] _ in
                self?.approveAuthWithUsernamelessQRCode(QRCodeResult, extraInfo: extras)
            }))
            self?.present(alert, animated: true, completion: nil)
        } failure: { error in
            print(error)
            
            self.dismiss(animated: true) {
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }

    func approveAuthWithUsernamelessQRCode(_ QRCodeResult: String, extraInfo: [FTRExtraInfo]?) {
        do {
            let accounts = try FTRClient.shared.getAccounts()
            let ac = UIAlertController(title: "Usernameless QR code", message: "Select an account", preferredStyle: .actionSheet)

            for account in accounts {
                ac.addAction(UIAlertAction(title: account.username ?? "Username N/A", style: .default, handler: { [weak self] _ in
                    self?.approveAuthWithUsernamelessQRCode(QRCodeResult, userId: account.userId, extraInfo: extraInfo)
                }))
            }

            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

            dismiss(animated: true) {
                self.present(ac, animated: true, completion: nil)
            }
        } catch {
            // Handle error
            print(error)
        }
    }

    func approveAuthWithUsernamelessQRCode(_ QRCodeResult: String, userId: String, extraInfo: [FTRExtraInfo]?) {
        FTRClient.shared.replyAuth(AuthReplyParameters.approveUsernamelessQRCode(QRCodeResult, userId: userId, extraInfo: extraInfo), success: { [weak self] in
            self?.dismiss(animated: true) {
                self?.showAlert(title: "Success", message: "User authenticated successfully!")
            }
        }, failure: { [weak self] error in
            self?.dismiss(animated: true) {
                self?.showAlert(title: "Error", message: error.localizedDescription)
            }
        })
    }

    func offlineAuthWithQRCode(_ QRCodeResult: String) {
        if FTRClient.qrCodeType(from: QRCodeResult) == .offlineAuth {
            self.showApproveOfflineAlertQRCode(QRCodeResult)
        } else {
            self.showAlert(title: "Error", message: "QR Code type is not offline.")
        }
    }

    @IBAction func totpWithPINTouchedUpInside(_ sender: Any) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
        vc.pinMode = .set
        vc.didFinishWithPin = { [weak self] pin in
            self?.totpAuth(sdkPin: pin)
        }

        dismiss(animated: true) {
            self.present(vc, animated: true, completion: nil)
        }
    }

    func totpAuth(sdkPin: String?) {
        do {
            guard let account = try FTRClient.shared.getAccounts().first else {
                self.showAlert(title: "Error", message: "No accounts available.")
                return
            }
            
            let parameters: TOTPParameters = operationWithBiometrics ?
            .with(userId: account.userId, promptReason: "Unlock SDK") :
            (sdkPin != nil ? .with(userId: account.userId, sdkPin: sdkPin!) : .with(userId: account.userId))
            
            operationWithBiometrics = false
            FTRClient.shared.getTOTP(parameters, success: { [weak self] totp in
                let title = "TOTP"
                let body = "Code: \(totp.totp) (remaining: \(totp.remainingSecs) sec)"
                self?.showAlert(title: title, message: body)
            }, failure: { [weak self] error in
                self?.showAlert(title: "Error", message: error.localizedDescription)
            })
        } catch {
            print(error)
        }
    }
}
