//
//  UserDefaultsService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJUserDefaultsServiceProtocol {
    associatedtype KeyType: MJKeyType
    func set<T>(_ key: KeyType, value: T)
    func get<T>(_ key: KeyType) -> T?
    func delete(_ key: KeyType)
    func deleteAll()
}

class MJUserDefaultsService<Key: MJKeyType>: MJUserDefaultsServiceAny<Key> {
    
    public override func set<T>(_ key: KeyType, value: T) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    public override func get<T>(_ key: KeyType) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
    
    public override func delete(_ key: KeyType) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    public override func deleteAll() {
        for key in KeyType.all {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}

class MJUserDefaultsServiceMock<Key: MJKeyType>: MJUserDefaultsServiceAny<Key> {
    
    private var store = [String: Any]()
    
    public override func set<T>(_ key: KeyType, value: T) {
        store[key.rawValue] = value
    }
    
    public override func get<T>(_ key: KeyType) -> T? {
        return store[key.rawValue] as? T
    }
    
    public override func delete(_ key: KeyType) {
        store.removeValue(forKey: key.rawValue)
    }
    
    public override func deleteAll() {
        store.removeAll()
    }
}

open class MJUserDefaultsServiceAny<Key: MJKeyType>: MJUserDefaultsServiceProtocol {
    public typealias KeyType = Key
    public func set<T>(_ key: Key, value: T) { }
    public func get<T>(_ key: Key) -> T? { return nil }
    public func delete(_ key: Key) { }
    public func deleteAll() { }
}
