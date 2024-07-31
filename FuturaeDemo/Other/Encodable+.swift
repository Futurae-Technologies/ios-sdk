//
//  Encodable+.swift
//  FuturaeDemo
//
//  Created by Armend Hasani on 13.12.23.
//  Copyright © 2023 Futurae. All rights reserved.
//

import Foundation

extension Encodable {
    func toDictionary() -> [String: Any] {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(self)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String: Any]
            return dictionary ?? [:]
        } catch {
            print("Error converting to dictionary: \(error)")
            return [:]
        }
    }
}
