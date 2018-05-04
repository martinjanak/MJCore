//
//  MJKeychain.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

internal final class MJKeychain {
    
    internal static func set(_ key: String, value: String) {
        DispatchQueue.global().sync(flags: .barrier) {
            save(value, forKey: key)
        }
    }
    
    internal static func delete(_ key: String) {
        DispatchQueue.global().sync(flags: .barrier) {
            save(nil, forKey: key)
        }
    }
    
    internal static func get(_ key: String) -> String? {
        return load(withKey: key)
    }
    
    private static func save(_ string: String?, forKey key: String) {
        let query = keychainQuery(withKey: key)
        let objectData: Data? = string?.data(using: .utf8, allowLossyConversion: false)
        
        if SecItemCopyMatching(query, nil) == noErr {
            if let dictData = objectData {
                _ = SecItemUpdate(query, NSDictionary(dictionary: [kSecValueData: dictData]))
            } else {
                _ = SecItemDelete(query)
            }
        } else {
            if let dictData = objectData {
                query.setValue(dictData, forKey: kSecValueData as String)
                _ = SecItemAdd(query, nil)
            }
        }
    }
    
    private static func load(withKey key: String) -> String? {
        let query = keychainQuery(withKey: key)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnData as String)
        query.setValue(kCFBooleanTrue, forKey: kSecReturnAttributes as String)
        
        var result: CFTypeRef?
        let status = SecItemCopyMatching(query, &result)
        
        guard
            let resultsDict = result as? NSDictionary,
            let resultsData = resultsDict.value(forKey: kSecValueData as String) as? Data,
            status == noErr
            else {
                return nil
        }
        return String(data: resultsData, encoding: .utf8)
    }
    
    private static func keychainQuery(withKey key: String) -> NSMutableDictionary {
        let result = NSMutableDictionary()
        result.setValue(kSecClassGenericPassword, forKey: kSecClass as String)
        result.setValue(key, forKey: kSecAttrService as String)
        result.setValue(kSecAttrAccessibleAlwaysThisDeviceOnly, forKey: kSecAttrAccessible as String)
        return result
    }
    
}
