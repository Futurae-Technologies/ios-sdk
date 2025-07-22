//
//  HistoryItem.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 8.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

class HistoryItem {
    let success: Bool
    let title: String
    let subtitle: String
    let date: String
    let result: String

    init(activity: FTRAccountActivity) {
        let details = activity.details
        let result = details.result
        
        self.success = result == "allow"
        self.title = details.type ?? "Action"

        let ip = details.trustedDeviceIp ?? "No location info"
        var ipText = ip
        
        if let countryCode = activity.loginDevCountry,
           let countryName = Locale.current.localizedString(forRegionCode: countryCode) {
            ipText = "\(countryName) (\(ip))"
        }
        
        self.subtitle = ipText
        self.result = result ?? ""

        let historyItemDateFormatter = DateFormatter()
        historyItemDateFormatter.setLocalizedDateFormatFromTemplate("ddMMMMYYYYjjm")
        let unixStr = activity.timestamp
        let unix = TimeInterval(unixStr)
        self.date = historyItemDateFormatter.string(from: Date(timeIntervalSince1970: unix))
    }
}
