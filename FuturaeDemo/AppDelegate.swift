//
//  AppDelegate.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UIKit
import FuturaeKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // push notifications
        let approveAction = UNNotificationAction(identifier: "approve", title: "Approve", options: [])
        let rejectAction = UNNotificationAction(identifier: "reject", title: "Reject", options: [.destructive])
        
        let approveCategory = UNNotificationCategory(identifier: "auth", actions: [approveAction, rejectAction], intentIdentifiers: [], options: [])
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([approveCategory])
        center.delegate = self
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
            // NOTE: To be completed
        }
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        window?.rootViewController?.present(ac, animated: true, completion: nil)
    }
    
    func showLocalNotification(title: String, withBody body: String) {
        let userInfo: [AnyHashable: Any] = [:] // Define userInfo as needed
        let request = createNotificationRequest(withBody: body, title: title, soundName: "default", category: "FTCATEGORY_APPROVE", userInfo: userInfo)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }

    func createNotificationRequest(withBody body: String, title: String, soundName: String, category: String, userInfo: [AnyHashable: Any]) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body

        if !category.isEmpty {
            content.categoryIdentifier = category
        }

        if !userInfo.isEmpty {
            content.userInfo = userInfo
        }

        if !soundName.isEmpty {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName))
        }

        return UNNotificationRequest(identifier: "Futurae", content: content, trigger: nil)
    }
    
    func unlockSDK(callback: @escaping () -> Void) {
        guard let method = FTRClient.shared.activeUnlockMethods.first else { return }

        switch method {
        case .biometrics, .biometricsOrPasscode:
            unlockWithBiometrics(callback: callback)
        case .sdkPin:
            unlockWithPIN(callback: callback)
        default:
            break
        }
    }

    func unlockWithPIN(callback: @escaping () -> Void) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "pinViewController") as! PinViewController
        vc.pinMode = .input
        vc.didFinishWithPin = { [weak self] pin in
            FTRClient.shared.unlock(UnlockParameters.with(sdkPin: pin ?? ""), success: {
                self?.window?.rootViewController?.dismiss(animated: true, completion: nil)
                callback()
            }, failure: { error in
                self?.window?.rootViewController?.dismiss(animated: true, completion: nil)
                callback()
            })
        }
        window?.rootViewController?.present(vc, animated: true, completion: nil)
    }

    func unlockWithBiometrics(callback: @escaping () -> Void) {
        FTRClient.shared.unlock(UnlockParameters.with(biometricsPrompt: "UNLOCK WITH BIOMETRICS"), success: {
            callback()
        }, failure: { error in
            callback()
        })
    }

}


extension AppDelegate: FTRNotificationDelegate {
    func approveAuthenticationReceived(_ authenticationInfo: FTRNotificationAuth) {
        if FTRClient.shared.isLocked {
            let ac = UIAlertController(title: "SDK IS LOCKED", message: "You need to unlock to proceed", preferredStyle: .alert)

            ac.addAction(UIAlertAction(title: "UNLOCK", style: .default, handler: { [weak self] _ in
                self?.unlockSDK {
                    DispatchQueue.main.async {
                        self?.approveAuthenticationReceived(authenticationInfo)
                    }
                }
            }))
            ac.addAction(UIAlertAction(title: "CANCEL", style: .destructive, handler: nil))

            window?.rootViewController?.present(ac, animated: false, completion: nil)
            return
        }

        print("Received approve authentication: \(authenticationInfo)")

        var extraInfoMsg = ""
        if let extraInfo = authenticationInfo.extraInfo {
            extraInfoMsg += "\n"
            for pair in extraInfo {
                extraInfoMsg += "\(pair.key)\n\(pair.value)\n"
            }
        }

        let sessionTimeout = authenticationInfo.sessionTimeout
        let numbersChallenge = authenticationInfo.multiNumberedChallenge
        var message = "Would you like to approve the request? \(extraInfoMsg)."
        
        if let sessionTimeout = authenticationInfo.sessionTimeout {
            message.append("\n\nSession timeout:\n\(sessionTimeout.intValue)")
        }
        
        if let timestamp = authenticationInfo.timeout?.doubleValue {
            let date = Date(timeIntervalSince1970: timestamp)            
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            let dateString = formatter.string(from: date)
            message.append("\n\nTimeout at:\n\(dateString)")
        }
        
        if let authType = authenticationInfo.type {
            message.append("\n\nType:\n\(authType)")
        }
        
        let ac = UIAlertController(title: "Approve", message: message, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Approve", style: .cancel, handler: { _ in
            if let numbersChallenge = numbersChallenge {
                self.pickMultiChallengeNumber(numbersChallenge) { number in
                    FTRClient.shared.replyAuth(AuthReplyParameters.approvePushMultiNumber(number, sessionId: authenticationInfo.sessionId, userId: authenticationInfo.userId, extraInfo: authenticationInfo.extraInfo), success: {
                        // Success handling
                    }, failure: { error in
                        print("Failed to approve: \(error)")
                    })
                }
            } else {
                FTRClient.shared.replyAuth(AuthReplyParameters.approvePush(authenticationInfo.sessionId, userId: authenticationInfo.userId, extraInfo: authenticationInfo.extraInfo), success: {
                    // Success handling
                }, failure: { error in
                    print("Failed to approve: \(error)")
                })
            }
        }))
        ac.addAction(UIAlertAction(title: "Deny", style: .destructive, handler: { _ in
            FTRClient.shared.replyAuth(AuthReplyParameters.rejectPush(authenticationInfo.sessionId, userId: authenticationInfo.userId, isFraud: false, extraInfo: authenticationInfo.extraInfo), success: {
                // Success handling
            }, failure: { error in
                print("Failed to approve: \(error)")
            })
        }))

        window?.rootViewController?.present(ac, animated: false, completion: nil)
    }

    func pickMultiChallengeNumber(_ numbers: [Int], callback: @escaping (Int) -> Void) {
        let ac = UIAlertController(title: "Multi Number Challenge", message: "Pick number", preferredStyle: .alert)

        for number in numbers {
            ac.addAction(UIAlertAction(title: "\(number)", style: .default, handler: { _ in
                callback(number)
            }))
        }

        window?.rootViewController?.present(ac, animated: false, completion: nil)
    }

    
    func unenrollUserReceived(_ userId: String) {
        //
    }
    
    func notificationError(_ error: Error) {
        //
    }
    
    func qrCodeScanRequested(_ sessionId: String, _ userId: String, _ timeout: TimeInterval) {
        //
        QRCodeScanRequestCoordinator.instance.notifyShouldScanQRCode()
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if FTRClient.sdkIsLaunched {
            FTRClient.shared.registerPushToken(deviceToken, success: {
                // Success handling code
            }, failure: { error in
                // Failure handling code
            })
        } else {
            let customDefaults = UserDefaults(suiteName: SDKConstants.APP_GROUP)
            customDefaults?.set(deviceToken, forKey: SDKConstants.DEVICE_TOKEN_KEY)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received APN with completionHandler: \(userInfo)")
            
        FTRClient.shared.handleNotification(userInfo, delegate: self)
        self.showLocalNotification(title: "Authentication Request", withBody: userInfo["body"] as? String ?? "")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        FTRClient.shared.handleNotification(notification.request.content.userInfo, delegate: self)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let authenticationInfo = response.notification.request.content.userInfo
        if response.actionIdentifier == "approve" || response.actionIdentifier == "reject" {
            guard let sessionId = authenticationInfo["session_id"] as? String,
                  let userId = authenticationInfo["user_id"] as? String else {
                return
            }
            
            FTRClient.shared.getSessionInfo(SessionParameters.with(id: sessionId,
                                                                    userId: userId),
                                            success: { data in
                FTRClient.shared.replyAuth(AuthReplyParameters.replyPush(response.actionIdentifier == "approve" ? .approve : .reject,
                                                                         sessionId: sessionId,
                                                                         userId: userId,
                                                                         extraInfo: data.extraInfo), success: {
                    // Success handling
                }, failure: { error in
                    print("Failed to approve: \(error)")
                })
            }, failure: { error in
                // Failure handling
            })

            return
        }
        
        FTRClient.shared.handleNotification(response.notification.request.content.userInfo, delegate: self)
    }
}

extension AppDelegate: FTROpenURLDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[.sourceApplication] as? String
        print("Received URL Scheme call from \(String(describing: sourceApplication)): \(url)")
        
        guard let vc = window?.rootViewController else { return true }

        switch FTRUtils.typeFromURL(url){
        case .activation:
            if let code = FTRUtils.activationDataFromURL(url)?.activationCode {
                vc.promptForBindingToken(callback: { token in
                    FTRClient.shared.enroll(token != nil ? EnrollParameters.with(activationCode: code, bindingToken: token!)
                                            : EnrollParameters.with(activationCode: code), success: {
                        vc.showAlert(title: "Success", message: "User account enrolled successfully!")
                    }, failure: { error in
                        vc.showAlert(title: "Error", message: error.localizedDescription)
                    })
                })
            }
        default:
            FTRClient.shared.openURL(url, options: options, delegate: self)
        }
        
        return true
    }
    
    
    func authenticationURLOpened(_ authenticationInfo: FTRURLAuth) {
        print("authenticationURLOpened: \(authenticationInfo)")

        let redirectUri = authenticationInfo.successUrlCallback
        authenticationURLFinished(redirectUri)
    }
    
    func authenticationURLFinished(_ redirectUri: String?) {
        if let redirectUri = redirectUri, !redirectUri.isEmpty {
            let ac = UIAlertController(title: "MobileAuth Success", message: "Would you like to open the callback?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Open", style: .cancel, handler: { _ in
                if let url = URL(string: redirectUri) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            window?.rootViewController?.present(ac, animated: false, completion: nil)
        } else {
            let ac = UIAlertController(title: "MobileAuth Success", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            window?.rootViewController?.present(ac, animated: false, completion: nil)
        }
    }

    func activationURLOpened(_ userId: String) {
        print("activationURLOpened userId: \(userId)")
        showAlert(title: "Success", message: "Successfully enrolled")
    }

    func openURLError(_ error: Error) {
        var message = (error as NSError).userInfo["msg"] as? String ?? error.localizedDescription
        message = message.isEmpty ? "Unknown error" : message
        
        print("openURLError: \(error)")
        showAlert(title: "Error", message: message)
    }
}
