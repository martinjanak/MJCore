//
//  MJHttpResponse.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

public enum MJHttpError: Error {
    case noConnection
    case invalidUrlComponents
    case invalidUrl
    case http(statusCode: Int)
    case noDataReturned
    case couldNotParseAsJson
    case couldNotAuthenticateRequest
    case timedOut
    case couldNotRefreshAuthentication
    
    public var isBadRequest: Bool {
        return isHttpError(400)
    }
    
    public var isUnauthenticated: Bool {
        return isHttpError(401)
    }
    
    public var isForbidden: Bool {
        return isHttpError(403)
    }
    
    public var isServerError: Bool {
        return isHttpError(500...599)
    }
    
    public func isHttpError(_ sc: Int) -> Bool {
        if case let .http(statusCode) = self {
            return statusCode == sc
        } else {
            return false
        }
    }
    
    public func isHttpError(_ range: ClosedRange<Int>) -> Bool {
        if case let .http(sc) = self {
            return range.contains(sc)
        } else {
            return false
        }
    }
    
}
