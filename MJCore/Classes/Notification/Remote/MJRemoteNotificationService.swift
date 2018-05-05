//
//  MJRemoteNotificationService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UIKit
import RxSwift

open class MJRemoteNotificationService {
    
    public typealias Payload = [AnyHashable: Any]
    
    private let notificationSubject = PublishSubject<MJRemoteNotification>()
    public lazy var notification = notificationSubject.asObservable()
    
    open func getToken() -> String? {
        fatalError("getToken() has not been implemented")
    }
    
    open func storeAndUpload(token: String) {
        fatalError("storeAndUpload(token:) has not been implemented")
    }
    
    open func deleteAndRevoke(token: String) {
        fatalError("deleteAndRevoke(token:) has not been implemented")
    }
    
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
        payload: Payload,
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        notificationSubject.onNext(
            MJRemoteNotification(
                payload: payload,
                completionHandler: completionHandler
            )
        )
    }
}