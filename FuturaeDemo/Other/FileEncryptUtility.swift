//
//  FileEncryptUtility.swift
//  AdaptiveKit
//
//  Created by Armend Hasani on 23.1.25.
//

import Foundation
import CommonCrypto

class FileEncryptUtility {
    private let keychainKey: String

    init(keychainKey: String) {
        self.keychainKey = keychainKey
        ensureEncryptionKeyExists()
    }

    private func ensureEncryptionKeyExists() {
        if loadKeyFromKeychain() == nil {
            let newKey = generateRandomEncryptionKey()
            saveKeyToKeychain(newKey)
        }
    }

    private func generateRandomEncryptionKey() -> Data {
        return Data((0..<32).map { _ in UInt8.random(in: 0...255) })
    }

    private func saveKeyToKeychain(_ key: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keychainKey,
            kSecValueData as String: key,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func loadKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keychainKey,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            return data
        } else {
            return nil
        }
    }

    func encrypt(data: Data) -> Data? {
        if let key = loadKeyFromKeychain() {
            let nonce = NSMutableData(length: 16) ?? .init()
            let _ = SecRandomCopyBytes(kSecRandomDefault, 16, nonce.mutableBytes)
            
            if let encryptedData = encryptAES256CTR(data, key: key, nonce: nonce as Data) {
                var concatNonceWithEncryptedData = Data()
                concatNonceWithEncryptedData.append(nonce as Data)
                concatNonceWithEncryptedData.append(encryptedData)
                return concatNonceWithEncryptedData
            }
        }
        
        return nil
    }

    func decrypt(data: Data) -> Data? {
        if let key = loadKeyFromKeychain() {
            let nonce = data.subdata(in: 0..<16)
            let encryptedData = data.subdata(in: 16..<data.count)
            
            return decryptAES256CTREncodedString(encryptedData, key: key, nonce: nonce)
        }
        
        return nil
    }

    private func encryptAES256CTR(_ data: Data, key: Data, nonce: Data) -> Data? {
        var cipherData = Data(count: data.count + kCCBlockSizeAES128)
        var cryptor: CCCryptorRef?
        
        let result = CCCryptorCreateWithMode(CCOperation(kCCEncrypt),
                                             CCMode(kCCModeCTR),
                                             CCAlgorithm(kCCAlgorithmAES),
                                             CCPadding(ccPKCS7Padding),
                                             nonce.withUnsafeBytes { $0.baseAddress },
                                             key.withUnsafeBytes { $0.baseAddress },
                                             key.count,
                                             nil,
                                             0,
                                             0,
                                             CCModeOptions(kCCModeOptionCTR_BE),
                                             &cryptor)
        
        if result != kCCSuccess {
            return nil
        }
        
        var outLength: size_t = 0
        
        let updateResult = CCCryptorUpdate(cryptor,
                                           data.withUnsafeBytes { $0.baseAddress },
                                           data.count,
                                           cipherData.withUnsafeMutableBytes { $0.baseAddress },
                                           cipherData.count,
                                           &outLength)
        
        if updateResult != kCCSuccess {
            return nil
        }
        
        cipherData.count = outLength
        
        let finalResult = CCCryptorFinal(cryptor,
                                         cipherData.withUnsafeMutableBytes { $0.baseAddress },
                                         cipherData.count,
                                         &outLength)
        
        if finalResult != kCCSuccess {
            return nil
        }
        
        CCCryptorRelease(cryptor)
        
        return cipherData
    }
    
    private func decryptAES256CTREncodedString(_ cipherData: Data, key: Data, nonce: Data) -> Data? {
        var cryptor: CCCryptorRef?
        let result = CCCryptorCreateWithMode(
            CCOperation(kCCDecrypt),
            CCMode(kCCModeCTR),
            CCAlgorithm(kCCAlgorithmAES),
            CCPadding(ccPKCS7Padding),
            nonce.bytes,
            key.bytes,
            key.count,
            nil,
            0,
            0,
            CCModeOptions(kCCModeOptionCTR_BE),
            &cryptor
        )
        
        guard result == kCCSuccess, let cryptor = cryptor else {
            return nil
        }
        
        let plainData = NSMutableData(length: cipherData.count + kCCBlockSizeAES128) ?? .init()
        var outLengthDecrypt: size_t = 0
        
        let updateResult = CCCryptorUpdate(
            cryptor,
            cipherData.bytes,
            cipherData.count,
            plainData.mutableBytes,
            plainData.count,
            &outLengthDecrypt
        )
        
        guard updateResult == kCCSuccess else {
            return nil
        }
        
        plainData.length = outLengthDecrypt
        
        let finalResult = CCCryptorFinal(
            cryptor,
            plainData.mutableBytes,
            plainData.count,
            &outLengthDecrypt
        )
        
        guard finalResult == kCCSuccess else {
            return nil
        }
        
        CCCryptorRelease(cryptor)
        return plainData as Data
    }
}

extension Data {
  var bytes: Array<UInt8> {
    Array(self)
  }
}
