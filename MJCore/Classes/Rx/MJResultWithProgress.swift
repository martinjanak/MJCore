//
//  MJResultWithProgress.swift
//  MJCore
//
//  Created by Martin Janák on 16/05/2018.
//

import Foundation

public enum MJResultWithProgressSimple<Progress> {
    case success
    case progress(value: Progress)
    case failure(error: Error)
}

public enum MJResultWithProgress<Value, Progress> {
    case success(value: Value)
    case progress(value: Progress)
    case failure(error: Error)
}

extension MJResultWithProgressSimple {
    
    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
}

extension MJResultWithProgress {
    
    public func isSuccess() -> Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    public func simplify() -> MJResultWithProgressSimple<Progress> {
        switch self {
        case .success:
            return .success
        case .progress(let value):
            return .progress(value: value)
        case .failure(let error):
            return .failure(error: error)
        }
    }
    
}
