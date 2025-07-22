//
//  FunctionsViewController.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit

class FunctionsViewController: UIViewController {

    // Outlets
    @IBOutlet weak var sessionMethod: UIButton!
    @IBOutlet weak var adaptiveButton: UIButton!
    @IBOutlet weak var adaptiveAuthButton: UIButton!
    @IBOutlet weak var adaptiveMigrationButton: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var serviceLogoImageView: UIImageView!
    @IBOutlet var pinButtons: [UIButton]!

    // Properties
    var enrollWithPin: Bool = false
    var offlineQRCodePin: String?
    var operationWithBiometrics = false

    // Date formatter
    var rfc2882DateFormatter: DateFormatter?

    // MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        messageLabel.isHidden = FTRClient.sdkIsLaunched
        stackView.isHidden = !FTRClient.sdkIsLaunched
        if FTRClient.sdkIsLaunched {
            let isNotPinView = FTRClient.shared.currentLockConfiguration.type != .sdkPinWithBiometricsOptional
            pinButtons.forEach { $0.isHidden = isNotPinView }
        }

        loadServiceLogo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        QRCodeScanRequestCoordinator.instance.subscribeToQREvent(self)
        
        if(UserDefaults.custom.bool(forKey: SDKConstants.ADAPTIVE_COLLECTIONS_ENABLED_KEY)){
            adaptiveButton.setTitle("Disable adaptive collections", for: .normal)
            adaptiveAuthButton.isHidden = false
            adaptiveMigrationButton.isHidden = false
            
            if(UserDefaults.custom.bool(forKey: SDKConstants.ADAPTIVE_ENABLED_AUTH_KEY)){
                adaptiveAuthButton.setTitle("Disable adaptive authentication", for: .normal)
            } else {
                adaptiveAuthButton.setTitle("Enable adaptive authentication", for: .normal)
            }
            
            if(UserDefaults.custom.bool(forKey: SDKConstants.ADAPTIVE_ENABLED_MIGRATION_KEY)){
                adaptiveMigrationButton.setTitle("Disable adaptive migration", for: .normal)
            } else {
                adaptiveMigrationButton.setTitle("Enable adaptive migration", for: .normal)
            }
        } else {
            adaptiveButton.setTitle("Enable adaptive collections", for: .normal)
            adaptiveAuthButton.isHidden = true
            adaptiveMigrationButton.isHidden = true
        }
        
        
        sessionMethod.setTitle(UserDefaults.custom.bool(forKey: SDKConstants.USE_UNPROTECTED_SESSION) ?
                               "Use protected session" : "Use unprotected session", for: .normal)
    }

    // MARK: - Actions

    // Other methods
    func loadServiceLogo() {
        guard FTRClient.sdkIsLaunched else {
            return
        }

        do {
            guard let account = try FTRClient.shared.getAccounts().first,
                  let serviceLogo = account.serviceLogo else {
                return
            }

            if let url = URL(string: serviceLogo) {
                DispatchQueue.global(qos: .default).async {
                    if let data = try? Data(contentsOf: url),
                       let image = UIImage(data: data) {
                        DispatchQueue.main.async { [weak self] in
                            self?.serviceLogoImageView.image = image
                        }
                    }
                }
            }
        } catch {
            // Handle error
            print(error)
        }
    }
    
    @IBAction func offlineQRCodeTouchedUpInside(_ sender: UIButton) {
        presentQRCodeControllerWithQRCodeType(.offlineAuth, sender: sender)
    }

    @IBAction func offlineQRCodeWithPINTouchedUpInside(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
        vc.pinMode = .set
        vc.didFinishWithPin = { [weak self] pin in
            self?.offlineQRCodePin = pin
            self?.presentQRCodeControllerWithQRCodeType(.offlineAuth, sender: sender)
        }

        dismiss(animated: true) {
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func offlineQRCodeWithBiometricsTouchedUpInside(_ sender: UIButton) {
        operationWithBiometrics = true
        presentQRCodeControllerWithQRCodeType(.offlineAuth, sender: sender)
    }
    
    @IBAction func onlineQRCodeTouchedUpInside(_ sender: UIButton) {
        presentQRCodeControllerWithQRCodeType(.onlineAuth, sender: sender)
    }

    @IBAction func scanQRCodeTouchedUpInside(_ sender: UIButton) {
        presentQRCodeControllerWithQRCodeType(.generic, sender: sender)
    }

    @IBAction func scanQRCodeWithPINTouchedUpInside(_ sender: UIButton) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
        vc.pinMode = .set
        vc.didFinishWithPin = { [weak self] pin in
            self?.offlineQRCodePin = pin
            self?.presentQRCodeControllerWithQRCodeType(.generic, sender: sender)
        }

        dismiss(animated: true) {
            self.present(vc, animated: true, completion: nil)
        }
    }

    @IBAction func scanQRCodeWithBiometricsTouchedUpInside(_ sender: UIButton) {
        operationWithBiometrics = true
        presentQRCodeControllerWithQRCodeType(.generic, sender: sender)
    }
    
    func handleGeneric(_ QRCodeResult: String) {
        switch FTRClient.qrCodeType(from: QRCodeResult) {
        case .enrollment:
            enrollWithQRCode(QRCodeResult)
        case .onlineAuth:
            showApproveAuthAlertQRCode(QRCodeResult)
        case .usernameless:
            showApproveAuthAlertUsernamelessQRCode(QRCodeResult)
        case .offlineAuth:
            offlineAuthWithQRCode(QRCodeResult)
        case .invalid:
            showAlert(title: "Error", message: "QR Code is invalid.")
        }
    }
    
    func showApproveOfflineAlertQRCode(_ QRCodeResult: String) {
        let extras = FTRClient.shared.extraInfoFromOfflineQRCode(QRCodeResult)
        let mutableFormattedExtraInfo = extras.reduce("") { result, extraInfo in
            result + "\(extraInfo.key): \(extraInfo.value)\n"
        }

        let title = "Approve"
        let message = "Request Information\n\(mutableFormattedExtraInfo)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Deny", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { [weak self] _ in
            self?.showOfflineQRCodeSignatureAlert(QRCodeResult: QRCodeResult)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func showOfflineQRCodeSignatureAlert(signature: String?, error: Error?) {
        let title: String
        let message: String

        if let error = error {
            title = "Error"
            message = error.localizedDescription
            showAlert(title: title, message: message)
        } else {
            title = "Confirm Transaction"
            message = "To Approve the transaction, enter: \(signature ?? "") in the browser"
            showAlert(title: title, message: message)
        }
    }
    
    func showOfflineQRCodeSignatureAlert(QRCodeResult: String) {
        let parameters: OfflineQRCodeParameters
        
        if operationWithBiometrics {
            operationWithBiometrics = false
            parameters = .with(qrCode: QRCodeResult, promptReason: "Unlock SDK")
        } else if let pin = offlineQRCodePin {
            offlineQRCodePin = nil
            parameters = .with(qrCode: QRCodeResult, sdkPin: pin)
        } else {
            parameters = .with(qrCode: QRCodeResult)
        }
        
        FTRClient.shared.getOfflineQRVerificationCode(parameters) { [weak self] code in
            self?.showOfflineQRCodeSignatureAlert(signature: code, error: nil)
        } failure: { [weak self] error in
            self?.offlineQRCodePin = nil
            self?.showOfflineQRCodeSignatureAlert(signature: nil, error: error)
        }
    }

    func presentQRCodeControllerWithQRCodeType(_ QRCodeType: QRCodeType, sender: UIButton? = nil) {
        let title = sender?.title(for: .normal) ?? ""
        let qrcodeVC = ExampleQRCodeViewController(title: title, QRCodeType: QRCodeType)
        qrcodeVC.delegate = self
        let navigationController = UINavigationController(rootViewController: qrcodeVC)
        present(navigationController, animated: true, completion: nil)
    }
}


extension FunctionsViewController: ExampleQRCodeReaderDelegate {
    func reader(_ reader: ExampleQRCodeViewController, didScanResult result: String?) {
        reader.stopScanning()
        
        guard let result = result else { return }
        
        dismiss(animated: true) { [unowned self] in
            let QRCodeType = reader.QRCodeType

            switch QRCodeType {
            case .enrollment:
                enrollWithQRCode(result)
            case .onlineAuth:
                showApproveAuthAlertQRCode(result)
            case .offlineAuth:
                showApproveOfflineAlertQRCode(result)
            case .generic:
                handleGeneric(result)
            }
        }
    }
    
    func readerDidCancel(_ reader: ExampleQRCodeViewController) {
        //
    }
}

extension FunctionsViewController: QRCodeScanRequestDelegate {
    func qrCodeScanRequested() {
        presentQRCodeControllerWithQRCodeType(.onlineAuth)
    }
}


