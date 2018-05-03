//
//  MJHttpResponse.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

public enum MJHttpResponse {
    
    case success(data: Data)
    case noConnection
    case errorCouldNotEncodeData(error: Error)
    case errorInvalidUrl
    case errorSystem(error: Error)
    case errorHttp(statusCode: Int)
    case errorNoDataReturned
    case errorCouldNotParseAsJson
    case errorCouldNotAuthorizeRequest
    case timedOut
    
    public var isBadRequest: Bool {
        return isHttpError(400)
    }
    
    public var isUnauthorized: Bool {
        return isHttpError(401)
    }
    
    public var isServerError: Bool {
        return isHttpError(500...599)
    }
    
    public func isHttpError(_ sc: Int) -> Bool {
        if case let .errorHttp(statusCode) = self {
            return statusCode == sc
        } else {
            return false
        }
    }
    
    public func isHttpError(_ range: ClosedRange<Int>) -> Bool {
        if case let .errorHttp(sc) = self {
            return range.contains(sc)
        } else {
            return false
        }
    }
    
    public var debug: String {
        switch self {
        case .success: return "Success"
        case .noConnection: return "No Connection"
        case .errorCouldNotEncodeData(let error): return "Could not encode Data: \(error)"
        case .errorInvalidUrl: return "Invalid URL"
        case .errorSystem(let error): return "System Error: \(error)"
        case .errorHttp(let statusCode): return "Http Error (\(statusCode))"
        case .errorNoDataReturned: return "No Data Returned"
        case .errorCouldNotParseAsJson: return "Could not parse Json"
        case .errorCouldNotAuthorizeRequest: return "Could not authorize request"
        case .timedOut: return "Timed out"
        }
    }
    
}
