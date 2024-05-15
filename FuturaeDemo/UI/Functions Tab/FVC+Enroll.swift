//
//  FunctionsViewController+Enroll.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

extension FunctionsViewController {
    @IBAction func enrollTouchedUpInside(_ sender: UIButton) {
        enrollWithPin = false
        presentQRCodeControllerWithQRCodeType(.enrollment, sender: sender)
    }

    @IBAction func enrollWithPinTouchedUpInside(_ sender: UIButton) {
        enrollWithPin = true
        presentQRCodeControllerWithQRCodeType(.enrollment, sender: sender)
    }

    @IBAction func enrollShortCodeTouchedUpInside(_ sender: UIButton) {
        enrollShortCodeWithPin(false)
    }

    @IBAction func enrollShortCodeWithPinTouchedUpInside(_ sender: UIButton) {
        enrollShortCodeWithPin(true)
    }
    
    func enrollWithQRCode(_ QRCodeResult: String) {
        promptForBindingToken { [unowned self] bindingToken in
            if enrollWithPin {
                guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
                vc.pinMode = .set
                vc.didFinishWithPin = { [weak self] pin in
                    FTRClient.shared.enroll(bindingToken != nil ? EnrollParameters.with(activationCode: QRCodeResult, sdkPin: pin ?? "", bindingToken: bindingToken!)
                                            : EnrollParameters.with(activationCode: QRCodeResult, sdkPin: pin ?? ""), success: {
                        self?.dismiss(animated: true) {
                            self?.showAlert(title: "Success", message: "User account enrolled successfully!")
                            self?.loadServiceLogo()
                        }
                    }, failure: { error in
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    })
                }

                dismiss(animated: true) {
                    self.present(vc, animated: true, completion: nil)
                }
            } else {
                FTRClient.shared.enroll(bindingToken != nil ? EnrollParameters.with(activationCode: QRCodeResult, bindingToken: bindingToken!) : EnrollParameters.with(activationCode: QRCodeResult), success: { [weak self] in
                    self?.dismiss(animated: true) {
                        self?.showAlert(title: "Success", message: "User account enrolled successfully!")
                        self?.loadServiceLogo()
                    }
                }, failure: { [weak self] error in
                    self?.dismiss(animated: true) {
                        self?.showAlert(title: "Error", message: error.localizedDescription)
                    }
                })
            }
        }
    }

    func enrollShortCodeWithPin(_ withPin: Bool) {
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
        
        promptForBindingToken { [unowned self] token in
            vc.pinLength = 19
            vc.secureText = false
            vc.pinMode = .shortCode
            vc.didFinishWithPin = { [unowned self] pin in
                dismiss(animated: false) { [unowned self] in
                    enrollWithShortCode(pin ?? "", enrollWithPin: withPin, bindingToken: token)
                }
            }

            present(vc, animated: true, completion: nil)
        }
    }

    func enrollWithShortCode(_ code: String, enrollWithPin withPin: Bool, bindingToken: String?) {
        if withPin {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as? PinViewController else { return }
            vc.pinMode = .set
            vc.didFinishWithPin = { [weak self] pin in
                FTRClient.shared.enroll(bindingToken != nil ? EnrollParameters.with(shortCode: code, sdkPin: pin ?? "", bindingToken: bindingToken!) : EnrollParameters.with(shortCode: code, sdkPin: pin ?? ""), success: {
                    self?.dismiss(animated: true) {
                        self?.showAlert(title: "Success", message: "User account enrolled successfully!")
                        self?.loadServiceLogo()
                    }
                }, failure: { error in
                    self?.showAlert(title: "Error", message: error.localizedDescription)
                })
            }

            present(vc, animated: true, completion: nil)
        } else {
            FTRClient.shared.enroll(bindingToken != nil ? EnrollParameters.with(shortCode:code, bindingToken: bindingToken!) : EnrollParameters.with(shortCode:code), success: {
                self.dismiss(animated: true) {
                    self.showAlert(title: "Success", message: "User account enrolled successfully!")
                    self.loadServiceLogo()
                }
            }, failure: { error in
                self.showAlert(title: "Error", message: error.localizedDescription)
            })
        }
    }
}
