//
//  KeyChainManager.swift
//  Weather
//
//  Created by Jason Jacob on 8/10/23.
// Manger/Helper class to work with keychain API for saving last location.
// Since location data is considered as private, decided to use keychain for
// security

import Foundation
import Security

class KeyChainManager {
    // MARK: Method to save a secret provided by the caller
    func saveSecret(secretService: String, secretKey: String, secretValue: String) -> Bool {
        if let data  = secretValue.data(using: .utf8) {
            let query: [String: Any] = [ kSecClass as String: kSecClassGenericPassword,
                                         kSecAttrService as String: secretService,
                                         kSecAttrAccount as String: secretKey,
                                         kSecValueData as String: data
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            return status == errSecSuccess
        }
        return false
    }

    // MARK: Method to retrieve a secret based on the key and service provided by the caller
    func fetchSecret(secretService: String, secretKey: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secretService,
            kSecAttrAccount as String: secretKey,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnData as String: kCFBooleanTrue!
        ]
        var keychainObj: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &keychainObj)

        if status == errSecSuccess, let fetchedSecret = keychainObj as? Data,
           let secretString = String(data: fetchedSecret, encoding: .utf8) {
            return secretString
        }
        return nil
    }

    // MARK: Method to update a secret based on the key and service provided by the caller
    func updateSecret(secretService: String, secretKey: String, newSecret: String) -> Bool {
        if deleteSecret(secretService: secretService, secretKey: secretKey) {
            return saveSecret(secretService: secretService, secretKey: secretKey, secretValue: newSecret)
        }
        return false
    }
    // MARK: Method to delete a secret
    private func deleteSecret(secretService: String, secretKey: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: secretService,
            kSecAttrAccount as String: secretKey
        ]
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}
