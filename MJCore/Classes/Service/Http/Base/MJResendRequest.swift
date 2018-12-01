//
//  MJResendRequest.swift
//  MJCore
//
//  Created by Martin Janák on 15/05/2018.
//

import Foundation

struct MJResendRequest {
    let request: URLRequest
    let handler: (MJResult<Data>) -> Void
}
