//
//  UserDefaults+.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 11.7.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var custom: UserDefaults {
        .init(suiteName: SDKConstants.APP_GROUP)!
    }
}
