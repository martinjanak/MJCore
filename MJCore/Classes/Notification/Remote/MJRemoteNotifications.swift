//
//  MJRemoteNotification.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public protocol MJRemoteNotifications {
    static func create(from payload: [AnyHashable: Any]) -> MJResult<Self>
}
