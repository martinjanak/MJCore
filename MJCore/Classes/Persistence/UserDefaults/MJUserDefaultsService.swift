//
//  UserDefaultsService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJUserDefaultsService {
    associatedtype KeyType: MJKeyType
    func set<T>(_ key: KeyType, value: T)
    func get<T>(_ key: KeyType) -> T?
    func delete(_ key: KeyType)
    func deleteAll()
}

extension MJUserDefaultsService {
    
    public func set<T>(_ key: KeyType, value: T) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    public func get<T>(_ key: KeyType) -> T? {
        return UserDefaults.standard.object(forKey: key.rawValue) as? T
    }
    
    public func delete(_ key: KeyType) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
    
    public func deleteAll() {
        for key in KeyType.all {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
    }
}
