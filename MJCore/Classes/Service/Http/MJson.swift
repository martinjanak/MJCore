//
//  MJson.swift
//  MJCore
//
//  Created by Martin Janák on 05/05/2018.
//

public typealias MJson = [String: Any]
public typealias MJsonArray = [MJson]

public enum MJsonError: Error {
    case couldNotParseAsJson
    case keyDoesNotExist(key: String)
    case objectTypeMismatch(key: String, expect: String)
    case arrayTypeMismatch(key: String)
    case valueTypeMismatch(key: String, expect: String, metatype: String)
    case couldNotSerializeToString
    case couldNotSerializeString
}

extension Dictionary where Key == String, Value == Any {
    
    // MARK: Getters and setters
    
    public func get<V>(_ key: String) throws -> V {
        if let anyValue = self[key] {
            if let value = anyValue as? V {
                return value
            } else {
                throw MJsonError.valueTypeMismatch(
                    key: key,
                    expect: String(describing: V.self),
                    metatype: String(describing: type(of: anyValue))
                )
            }
        } else {
            throw MJsonError.keyDoesNotExist(key: key)
        }
    }
    
    public func getObject<V: MJsonParsable>(_ key: String) throws -> V {
        if let anyValue = self[key] {
            if let json = anyValue as? MJson {
                return try V.init(json: json)
            } else {
                throw MJsonError.objectTypeMismatch(
                    key: key,
                    expect: String(describing: V.self)
                )
            }
        } else {
            throw MJsonError.keyDoesNotExist(key: key)
        }
    }
    
    public func getArray<V: MJsonParsable>(_ key: String) throws -> [V] {
        if let anyValue = self[key] {
            if let jsonArray = anyValue as? MJsonArray {
                var array = [V]()
                for json in jsonArray {
                    array.append(try V(json: json))
                }
                return array
            } else {
                throw MJsonError.arrayTypeMismatch(key: key)
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
    
    public func getObjectOptional<V: MJsonParsable>(_ key: String) throws -> V? {
        if let anyValue = self[key] {
            if let json = anyValue as? MJson {
                return try V(json: json)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public func getArrayOptional<V: MJsonParsable>(_ key: String) -> [V]? {
        if let jsonArray = self[key] as? MJsonArray {
            do {
                var array = [V]()
                for json in jsonArray {
                    array.append(try V(json: json))
                }
                return array
            } catch {
                return nil
            }
        } else {
            return nil
        }
    }
    
    public mutating func set<V>(key: String, value: V) {
        self[key] = value as Any
    }
    
    // MARK: Parse
    
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
    
    public static func parseModel<Model: MJsonParsable>(
        _ data: Data,
        key: String? = nil,
        defaults: MJson? = nil
    ) throws -> Model {
        var json: MJson
        let jsonParsed = try MJson.parse(data)
        if let key = key {
            json = try jsonParsed.get(key)
        } else {
            json = jsonParsed
        }
        if let defaults = defaults {
            json.merge(defaults, uniquingKeysWith: { a, _ in a })
        }
        return try Model(json: json)
    }
    
    public static func parseModelOptional<Model: MJsonParsable>(
        _ data: Data,
        key: String? = nil,
        defaults: MJson? = nil
    ) -> Model? {
        do {
            var json: MJson
            let jsonParsed = try MJson.parse(data)
            if let key = key {
                json = try jsonParsed.get(key)
            } else {
                json = jsonParsed
            }
            if let defaults = defaults {
                json.merge(defaults, uniquingKeysWith: { a, _ in a })
            }
            return try Model(json: json)
        } catch {
            return nil
        }
    }
    
    public static func parseArrayModel<Model: MJsonParsable>(
        _ data: Data,
        key: String? = nil,
        defaults: MJson? = nil
    ) throws -> [Model] {
        let jsonArray: MJsonArray
        if let key = key {
            let json = try MJson.parse(data)
            jsonArray = try json.get(key)
        } else {
            jsonArray = try MJson.parseArray(data)
        }
        var modelArray = [Model]()
        if let defaults = defaults {
            for json in jsonArray {
                var jsonCopy = json
                jsonCopy.merge(defaults, uniquingKeysWith: { a, _ in a })
                modelArray.append(try Model(json: jsonCopy))
            }
        } else {
            for json in jsonArray {
                modelArray.append(try Model(json: json))
            }
        }
        return modelArray
    }
    
    // MARK: Serialize
    
    public func serialize() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    public func serializeOptional() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            return nil
        }
    }
    
    // MARK: Strings
    
    public func toString() throws -> String {
        let jsonData = try self.serialize()
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            throw MJsonError.couldNotSerializeToString
        }
    }
    
    public func toStringOptional() -> String? {
        if let jsonData = self.serializeOptional(),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
    public static func parse(string: String) throws -> MJson {
        guard let data = string.data(using: .utf8) else {
            throw MJsonError.couldNotSerializeString
        }
        return try MJson.parse(data)
    }
    
    public static func parseOptional(string: String) -> MJson? {
        if let data = string.data(using: .utf8),
            let json = MJson.parseOptional(data) {
            return json
        }
        return nil
    }
    
    public static func parseArray(string: String) throws -> MJsonArray {
        guard let data = string.data(using: .utf8) else {
            throw MJsonError.couldNotSerializeString
        }
        return try MJson.parseArray(data)
    }
    
    public static func parseArrayOptional(string: String) -> MJsonArray? {
        if let data = string.data(using: .utf8),
            let jsonArray = MJson.parseArrayOptional(data) {
            return jsonArray
        }
        return nil
    }
    
}

extension Array where Element == MJson {
    
    // MARK: Serialize
    
    public func serialize() throws -> Data {
        return try JSONSerialization.data(withJSONObject: self, options: [])
    }
    
    public func serializeOptional() -> Data? {
        do {
            return try JSONSerialization.data(withJSONObject: self, options: [])
        } catch {
            return nil
        }
    }
    
    // MARK: Strings
    
    public func toString() throws -> String {
        let jsonData = try self.serialize()
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        } else {
            throw MJsonError.couldNotSerializeToString
        }
    }
    
    public func toStringOptional() -> String? {
        if let jsonData = self.serializeOptional(),
            let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return nil
    }
    
}


