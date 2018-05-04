//
//  MJRemoteNotification.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import Foundation

public struct MJRemoteNotification {
    let payload: MJRemoteNotificationService.Payload
    let completionHandler: (UIBackgroundFetchResult) -> Void
}
