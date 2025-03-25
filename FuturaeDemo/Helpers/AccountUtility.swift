//
//  AccountUtility.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 25.3.25.
//  Copyright © 2025 Futurae. All rights reserved.
//

import Foundation
import FuturaeKit

@objc class AccountUtility: NSObject {
    @objc class func createAccountDescription(_ account: FTRAccount) -> String {
        var info = ""
        let enrolledAt = account.enrolled_at
        info += "username: \(account.user_id ?? "")\n"
        info += "  enrolled: \(account.enrolled ? "YES" : "NO")\n"
        info += "  enrolledAt: \(enrolledAt ?? "")\n"
        return info
    }
}
