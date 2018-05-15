//
//  MJson.swift
//  MJCore
//
//  Created by Martin Janák on 05/05/2018.
//

public typealias MJson = [String: Any]
public typealias MJsonArray = [MJson]

public class MJsonUtil {
    
    public static func parse(_ data: Data) -> MJson? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? MJson
        } catch {
            return nil
        }
    }
    
    public static func parseArray(_ data: Data) -> MJsonArray? {
        do {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? MJsonArray
        } catch {
            return nil
        }
    }
    
}


