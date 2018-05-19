//
//  MJson.swift
//  MJCore
//
//  Created by Martin Janák on 05/05/2018.
//

public typealias MJson = [String: Any]
public typealias MJsonArray = [MJson]

extension Dictionary where Key == String, Value == Any {
    
    public func get<V>(_ key: String) throws -> V {
        if let anyValue = self[key] {
            if let value = anyValue as? V {
                return value
            } else {
                throw MJsonError.valueTypeMismatch(key: key)
            }
        } else {
            throw MJsonError.keyDoesNotExist(key: key)
        }
    }
    
    public func getOptional<V>(_ key: String) -> V? {
        if let value = self[key] as? V {
            return value
        } else {
            return nil
        }
    }
    
    public mutating func set<V>(key: String, value: V) {
        self[key] = value as Any
    }
    
}

public class MJsonUtil {
    
    public static func parse(_ data: Data) throws -> MJson {
        let rawJson = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let json = rawJson as? MJson {
            return json
        } else {
            throw MJsonError.couldNotParseAsJson
        }
    }
    
    public static func parseArray(_ data: Data) throws -> MJsonArray {
        let rawJson = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        if let json = rawJson as? MJsonArray {
            return json
        } else {
            throw MJsonError.couldNotParseAsJson
        }
    }
    
    public static func parseOptional(_ data: Data) -> MJson? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? MJson {
                return json
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    public static func parseArrayOptional(_ data: Data) -> MJsonArray? {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? MJsonArray {
                return json
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    public static func serialize(_ json: MJson) throws -> Data {
        return try JSONSerialization.data(withJSONObject: json, options: [])
    }
    
    public static func serialize(_ jsonArray: MJsonArray) throws -> Data {
        return try JSONSerialization.data(withJSONObject: jsonArray, options: [])
    }
    
    public static func serializeOptional(_ json: MJson) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: json, options: [])
        } catch {
            return nil
        }
    }
    
    public static func serializeOptional(_ jsonArray: MJsonArray) -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: jsonArray, options: [])
        } catch {
            return nil
        }
    }
    
}

public enum MJsonError: Error {
    case couldNotParseAsJson
    case keyDoesNotExist(key: String)
    case valueTypeMismatch(key: String)
}


