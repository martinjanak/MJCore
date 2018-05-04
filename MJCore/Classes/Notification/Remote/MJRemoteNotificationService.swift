//
//  MJRemoteNotificationService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UIKit

public protocol MJRemoteNotificationService {
    associatedtype Notification: MJRemoteNotifications
    
    func getToken() -> String?
    func storeAndUpload(token: String)
    func deleteAndRevoke(token: String)
    func received(
        notificationResult: MJResult<Notification>,
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
}

extension MJRemoteNotificationService {
    
    public func register() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    public func unregister() {
        if let deviceToken = getToken() {
            deleteAndRevoke(token: deviceToken)
        }
    }
    
    public func didRegister(_ deviceToken: Data) {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        if let lastToken = getToken(),
            token == lastToken {
            return
        }
        storeAndUpload(token: token)
    }
    
    public func didReceive(
        payload: [AnyHashable: Any],
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        let notificationResult = Notification.create(from: payload)
        received(
            notificationResult: notificationResult,
            completionHandler: completionHandler
        )
    }
    
}
