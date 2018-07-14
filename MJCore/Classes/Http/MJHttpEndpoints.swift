//
//  MJHttpEndpoints.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation

public protocol MJHttpEndpoints {
    var domainUrl: String { get }
    var path: String { get }
    var method: MJHttpMethod { get }
    var query: [String: String]? { get }
    var additionalHeaders: [String: String]? { get }
    func getPayloadData() throws -> Data?
    func getTestData() throws -> Data?
}

extension MJHttpEndpoints {
    
    public var query: [String: String]? {
        return nil
    }
    
    public var additionalHeaders: [String: String]? {
        return nil
    }
    
    public func getPayloadData() throws -> Data? {
        return nil
    }
    
    public func getTestData() throws -> Data? {
        return nil
    }
    
}
