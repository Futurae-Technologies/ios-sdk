//
//  FileStorageUtility.swift
//  AdaptiveKit
//
//  Created by Armend Hasani on 24.1.25.
//

import Foundation

class FileStorageUtility {
    private let directoryPath: String

    init(directoryPath: String, excludeFromBackup: Bool) {
        self.directoryPath = directoryPath
        
        if excludeFromBackup {
            excludeDirectoryFromBackup()
        }
    }

    private func excludeDirectoryFromBackup() {
        let directory = pathForDirectory(directory: directoryPath)
        var directoryURL = URL(fileURLWithPath: directory, isDirectory: true)

        do {
            if !FileManager.default.fileExists(atPath: directory) {
                try FileManager.default.createDirectory(atPath: directory, withIntermediateDirectories: true)
            }

            var resourceValues = URLResourceValues()
            resourceValues.isExcludedFromBackup = true
            try directoryURL.setResourceValues(resourceValues)
        } catch {}
    }

    private func documentsPath() -> String! {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    }

    private func pathForDirectory(directory: String) -> String {
        directory.isEmpty ? documentsPath() : documentsPath().appending("/\(directory)")
    }

    private func pathForDirectory(directory: String, withName name: String) -> String {
        directory.isEmpty ? documentsPath().appending("/\(name)") : documentsPath().appending("/\(directory)/\(name)")
    }

    func writeFile(data: Data, fileName: String) throws {
        let fileURL = URL(fileURLWithPath: pathForDirectory(directory: directoryPath, withName: fileName))
        try data.write(to: fileURL, options: .atomic)
    }

    func readFile(fileName: String) throws -> Data? {
        let fileURL = URL(fileURLWithPath: pathForDirectory(directory: directoryPath, withName: fileName))
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return try Data(contentsOf: fileURL)
    }
    
    func deleteFile(fileName: String) throws {
        try FileManager.default.removeItem(atPath: pathForDirectory(directory: directoryPath, withName: fileName))
    }
    
    func contentsOfDirectory() throws -> [String] {
        try FileManager.default
            .contentsOfDirectory(atPath: pathForDirectory(directory: directoryPath))
    }
}
