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
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        guard let bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent) else {
            contentHandler(request.content)
            return
        }
        
        guard UserDefaults(suiteName: SDKConstants.APP_GROUP)?.bool(forKey: "app_group_enabled") == true else {
            contentHandler(bestAttemptContent)
            return
        }
        
        if let encrypted = bestAttemptContent.userInfo[SDKConstants.EXTRA_INFO_ENC_KEY] as? String,
           let userId = bestAttemptContent.userInfo[SDKConstants.USER_ID_KEY] as? String {
            
            let lockType: LockConfigurationType = .init(rawValue: UserDefaults.custom.integer(forKey: SDKConstants.KEY_CONFIG)) ?? .none
            
            do {
                try FTRClient.launch(config: FTRConfig(sdkId: SDKConstants.SDKID,
                                                       sdkKey: SDKConstants.SDKKEY,
                                                       baseUrl: SDKConstants.SDKURL,
                                                       keychain: FTRKeychainConfig(accessGroup: SDKConstants.KEYCHAIN_ACCESS_GROUP),
                                                       lockConfiguration: LockConfiguration(type: lockType,
                                                                                            unlockDuration: 60,
                                                                                            invalidatedByBiometricsChange: true)
                                                       ,appGroup: SDKConstants.APP_GROUP
                                                      ))
                
                if let decrypted = try? FTRClient.shared.decryptExtraInfo(encrypted, userId: userId) {
                    bestAttemptContent.categoryIdentifier = "auth"
                    bestAttemptContent.body =  decrypted.compactMap {
                        "\($0.key): \($0.value)"
                    }.joined(separator: ", ")
                }
            } catch {}
            
            contentHandler(bestAttemptContent)
        } else {
            contentHandler(bestAttemptContent)
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
