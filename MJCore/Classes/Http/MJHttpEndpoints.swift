//
//  MJHttpEndpoints.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation

public protocol MJHttpEndpoints {
    var path: String { get }
    var method: MJHttpMethod { get }
    func getPayloadData() throws -> Data?
    func getTestData() throws -> Data?
}

extension MJHttpEndpoints {
    func getTestData() throws -> Data? {
        return nil
    }
}
