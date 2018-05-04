//
//  MJKeychainService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJKeychainService {
    associatedtype KeyType: RawRepresentable where KeyType.RawValue == String
    func set(key: KeyType, value: String)
    func get(key: KeyType) -> String?
    func get(key: KeyType, defaultValue: String) -> String
    func delete(key: KeyType)
}

extension MJKeychainService {
    
    public func set(key: KeyType, value: String) {
        MJKeychain.set(key.rawValue, value: value)
    }
    
    public func get(key: KeyType) -> String? {
        return MJKeychain.get(key.rawValue)
    }
    
    public func get(key: KeyType, defaultValue: String) -> String {
        if let value = MJKeychain.get(key.rawValue) {
            return value
        }
        return defaultValue
    }
    
    public func delete(key: KeyType) {
        MJKeychain.delete(key.rawValue)
    }
}
