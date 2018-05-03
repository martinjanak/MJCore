//
//  MJCodableUtil.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation

public class MJCodableUtil {
    
    public static func decode<D: Decodable>(decodableType: D.Type, data: Data, handler: @escaping (D?, Error?) -> Void) {
        let decoder = JSONDecoder()
        do {
            let decodable = try decoder.decode(decodableType.self, from: data)
            handler(decodable, nil)
        } catch let error {
            handler(nil, error)
        }
    }
    
    public static func decode<D: Decodable>(decodableType: D.Type, data: Data) throws -> D {
        let decoder = JSONDecoder()
        return try decoder.decode(decodableType, from: data)
    }
    
    public static func encode<E: Encodable>(encodable: E, handler: @escaping (Data?, Error?) -> Void) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(encodable)
            handler(data, nil)
        } catch let error {
            handler(nil, error)
        }
    }
    
    public static func encode<E: Encodable>(encodable: E) throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(encodable)
    }
}
