//
//  MJKeychainService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJKeychainServiceProtocol {
    associatedtype KeyType: MJKeyType
    func set(_ key: KeyType, value: String)
    func get(_ key: KeyType) -> String?
    func delete(_ key: KeyType)
    func deleteAll()
}

public final class MJKeychainService<Key: MJKeyType>: MJKeychainServiceAny<Key> {
    
    public override func set(_ key: Key, value: String) {
        MJKeychain.set(key.rawValue, value: value)
    }
    
    public override func get(_ key: Key) -> String? {
        return MJKeychain.get(key.rawValue)
    }
    
    public override func delete(_ key: Key) {
        MJKeychain.delete(key.rawValue)
    }
    
    public override func deleteAll() {
        for key in Key.all {
            MJKeychain.delete(key.rawValue)
        }
    }
    
}

public final class MJKeychainServiceMock<Key: MJKeyType>: MJKeychainServiceAny<Key> {
    
    private var store = [String: String]()
    
    public override func set(_ key: Key, value: String) {
        store[key.rawValue] = value
    }
    
    public override func get(_ key: Key) -> String? {
        return store[key.rawValue]
    }
    
    public override func delete(_ key: Key) {
        store.removeValue(forKey: key.rawValue)
    }
    
    public override func deleteAll() {
        store.removeAll()
    }
}

open class MJKeychainServiceAny<Key: MJKeyType> {
    public init() { }
    public func set(_ key: Key, value: String) { }
    public func get(_ key: Key) -> String? { return nil }
    public func delete(_ key: Key) { }
    public func deleteAll() { }
}
