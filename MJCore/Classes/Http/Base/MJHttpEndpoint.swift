//
//  MJHttpEndpoints.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation

public protocol MJHttpEndpoint {
    var domainUrl: String { get }
    var path: String { get }
    var method: MJHttpMethod { get }
    
    var query: [String: String]? { get }
    var headers: [String: String]? { get }
    func getPayloadData() throws -> Data?
    func getTestData() throws -> Data?
}

extension MJHttpEndpoint {
    
    public var query: [String: String]? {
        return nil
    }
    
    public var headers: [String: String]? {
        return nil
    }
    
    public func getPayloadData() throws -> Data? {
        return nil
    }
    
    public func getTestData() throws -> Data? {
        return nil
    }
    
}
