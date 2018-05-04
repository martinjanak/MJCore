//
//  UserDefaultsService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJUserDefaultsService {
    associatedtype KeyType: RawRepresentable where KeyType.RawValue == String
    func set<T>(key: KeyType, value: T)
    func get<T>(key: KeyType) -> T?
    func get<T>(key: KeyType, defaultValue: T) -> T
    func delete(key: KeyType)
}

extension MJUserDefaultsService {
    
    public func set<T>(key: KeyType, value: T) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    public func get<T>(key: KeyType) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
    
    public func get<T>(key: KeyType, defaultValue: T) -> T {
        if let object: T = get(key: key) {
            return object
        }
        return defaultValue
    }
    
    public func delete(key: KeyType) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}
