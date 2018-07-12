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
    var query: [String: String]? { get }
    var method: MJHttpMethod { get }
    var additionalHeaders: [String: String]? { get }
    func getPayloadData() throws -> Data?
    func getTestData() throws -> Data?
}

extension MJHttpEndpoints {
    func getTestData() throws -> Data? {
        return nil
    }
}
