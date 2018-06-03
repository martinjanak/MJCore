//
//  MJKeychainService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJKeychainService {
    associatedtype KeyType: MJKeyType
    func set(_ key: KeyType, value: String)
    func get(_ key: KeyType) -> String?
    func delete(_ key: KeyType)
    func deleteAll()
}

extension MJKeychainService {
    
    public func set(_ key: KeyType, value: String) {
        MJKeychain.set(key.rawValue, value: value)
    }
    
    public func get(_ key: KeyType) -> String? {
        return MJKeychain.get(key.rawValue)
    }
    
    public func delete(_ key: KeyType) {
        MJKeychain.delete(key.rawValue)
    }
    
    public func deleteAll() {
        for key in KeyType.all {
            MJKeychain.delete(key.rawValue)
        }
    }
    
}
