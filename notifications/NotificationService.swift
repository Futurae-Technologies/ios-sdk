//
//  NotificationService.swift
//  notifications
//
//  Created by Armend Hasani on 22.5.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import UserNotifications
import FuturaeKit

class NotificationService: UNNotificationServiceExtension {
    var config: FTRConfig {
        let type: LockConfigurationType = .init(rawValue: UserDefaults.custom.integer(forKey: SDKConstants.KEY_CONFIG)) ?? .none
        let allowChangePin = UserDefaults.custom.bool(forKey: SDKConstants.ALLOW_CHANGE_PIN)
        let invalidatedByBiometricsChange = UserDefaults.custom.bool(forKey: SDKConstants.INVALIDATED_BY_BIOMETRICS_CHANGE)
        let setKeychainAccessGroup = UserDefaults.custom.bool(forKey: SDKConstants.SET_KEYCHAIN_ACCESS_GROUP)
        let setAppGroup = UserDefaults.custom.bool(forKey: SDKConstants.SET_APP_GROUP)
        let whenUnlockedThisDeviceOnly = UserDefaults.custom.bool(forKey: SDKConstants.WHEN_UNLOCKED_THIS_DEVICE_ONLY)
        let deactivateBiometricsAfterChangePin = UserDefaults.custom.bool(forKey: SDKConstants.DEACTIVATE_BIOMETRICS_AFTER_CHANGE_PIN)
        let sslPinning = UserDefaults.custom.bool(forKey: SDKConstants.SSL_PINNING)
        
        return FTRConfig(sdkId: SDKConstants.SDKID,
                         sdkKey: SDKConstants.SDKKEY,
                         baseUrl: SDKConstants.SDKURL,
                         keychain: FTRKeychainConfig(accessGroup: setKeychainAccessGroup ? SDKConstants.KEYCHAIN_ACCESS_GROUP : nil,
                                                     itemsAccessibility: whenUnlockedThisDeviceOnly ? .whenUnlockedThisDeviceOnly : .afterFirstUnlockThisDeviceOnly),
                         lockConfiguration: LockConfiguration(type: type,
                                                              unlockDuration: 60,
                                                              invalidatedByBiometricsChange: invalidatedByBiometricsChange,
                                                              pinConfiguration: .init(allowPinChangeWithBiometricUnlock: allowChangePin, deactivateBiometricsAfterPinChange: deactivateBiometricsAfterChangePin)),
                         appGroup: setAppGroup ? SDKConstants.APP_GROUP : nil,
                         sslPinning: sslPinning
        )
    }
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        if let encrypted = bestAttemptContent.userInfo[SDKConstants.EXTRA_INFO_ENC_KEY] as? String,
           let userId = bestAttemptContent.userInfo[SDKConstants.USER_ID_KEY] as? String {
            if !launchSDK(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler){
                return
            }
            
            if let decrypted = try? FTRClient.shared.decryptExtraInfo(encrypted, userId: userId) {
                bestAttemptContent.body =  decrypted.compactMap {
                    "\($0.key): \($0.value)"
                }.joined(separator: ", ")
            }
            
            contentHandler(bestAttemptContent)
            return
        }
        
        if let notificationId = request.content.userInfo[SDKConstants.NOTIFICATION_ID_KEY] as? String {
            if !launchSDK(bestAttemptContent: bestAttemptContent, contentHandler: contentHandler){
                return
            }
            
            FTRClient.shared.getNotificationData(notificationId) { data in
                let payload =  data.payload.compactMap {
                    "\($0.key): \($0.value)"
                }.joined(separator: ", ")
                bestAttemptContent.body = "Arbitrary Push Notification \(data.notificationId), \(data.userId) \(payload)"
                contentHandler(bestAttemptContent)
            } failure: { error in
                bestAttemptContent.body = error.localizedDescription
                contentHandler(bestAttemptContent)
            }
        } else {
            bestAttemptContent.categoryIdentifier = SDKConstants.NOTIFICATION_AUTH_CATEGORY
            contentHandler(bestAttemptContent)
        }
    }
    
    func launchSDK(bestAttemptContent: UNMutableNotificationContent, contentHandler: @escaping (UNNotificationContent) -> Void) -> Bool {
        if FTRClient.sdkIsLaunched {
            return true
        }
        
        do {
            try FTRClient.launch(config: config)
            return true
        } catch let error {
            bestAttemptContent.body = error.localizedDescription
            contentHandler(bestAttemptContent)
            return false
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
