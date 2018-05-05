//
//  MJResult.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public enum MJResultSimple {
    case success
    case failure(error: Error)
}

public enum MJResult<Value> {
    case success(value: Value)
    case failure(error: Error)
}

extension MJResultSimple {
    
    public init(_ capturing: () throws -> Void) {
        do {
            try capturing()
            self = .success
        } catch let error {
            self = .failure(error: error)
        }
    }
    
    public func unwrap() throws -> Void {
        switch self {
        case .success: return
        case .failure(let error): throw error
        }
    }
    
    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

extension MJResult {
    
    public init(_ capturing: () throws -> Value) {
        do {
            self = .success(value: try capturing())
        } catch let error {
            self = .failure(error: error)
        }
    }
    
    public func unwrap() throws -> Value {
        switch self {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
    
    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
