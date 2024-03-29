//
//  AdaptiveDebugStorage.swift
//  AdaptiveKit
//
//  Created by Armend Hasani on 31.10.22.
//

import Foundation

@objc
class AdaptiveDebugStorage: NSObject {
    private static let instance = AdaptiveDebugStorage()
    private let directoryPath = "adaptive-collections"
    private let timestampKey = "timestamp"
        
    @objc
    class func shared() -> AdaptiveDebugStorage {
        return instance
    }

    private func documentsPath() -> String! {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }

    private func pathForDirectory(directory:String) -> String {
        documentsPath().appending("/\(directory)")
    }

    private func pathForDirectory(directory:String, withName name:String) -> String {
        documentsPath().appending("/\(directory)/\(name)")
    }

    @objc
    func save(_ collection: [String: Any]) {
        guard let timestamp = (collection[timestampKey] as? Double)?.description else { return }
        
        do {
            if !FileManager.default.fileExists(atPath: pathForDirectory(directory: directoryPath)) {
                try FileManager.default.createDirectory(atPath: pathForDirectory(directory: directoryPath), withIntermediateDirectories: true)
            }
            
            let data = try JSONSerialization.data(withJSONObject: collection)
            try data.write(to: URL(fileURLWithPath: pathForDirectory(directory: directoryPath, withName: timestamp)))
        } catch let error {
            print(error)
        }
    }

    @objc
    func delete(_ collection: [String: Any]) {
        guard let timestamp = (collection[timestampKey] as? Double)?.description else { return }
        
        do {
            try FileManager.default.removeItem(atPath: pathForDirectory(directory: directoryPath, withName: timestamp))
        } catch let error {
            print(error)
        }
    }

    @objc
    func savedCollections() -> [[String: Any]] {
        do {
            return try FileManager.default
                .contentsOfDirectory(atPath: pathForDirectory(directory: directoryPath))
                .compactMap { getInDirectory(withName: $0) }
        } catch let error {
            print(error)
            return []
        }
    }
    
    private func getInDirectory(withName name:String!) -> [String: Any]? {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: pathForDirectory(directory: directoryPath, withName: name)))
            let collection = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return collection
        } catch let error {
            print(error)
            return nil
        }
    }
}
