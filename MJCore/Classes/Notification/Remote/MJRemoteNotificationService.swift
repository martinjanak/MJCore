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
    
    private let notificationSubject: PublishSubject<MJRemoteNotification>
    public lazy var notification = notificationSubject.asObservable()
    
    public init() {
        notificationSubject = PublishSubject<MJRemoteNotification>()
    }
    
    open func getToken() -> String? {
        fatalError("getToken() has not been implemented")
    }
    
    open func storeAndUpload(token: String) -> MJHttpResponse {
        fatalError("storeAndUpload(token:) has not been implemented")
    }
    
    open func deleteAndRevoke(token: String) -> MJHttpResponse {
        fatalError("deleteAndRevoke(token:) has not been implemented")
    }
    
    public func register() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    public func unregister() -> Observable<MJResultSimple> {
        if let deviceToken = getToken() {
            return deleteAndRevoke(token: deviceToken).simplify()
        } else {
            return Observable<MJResultSimple>.just(.success)
        }
    }
    
    public func didRegister(_ deviceToken: Data) -> Observable<MJResultSimple> {
        
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        if let lastToken = getToken(),
            token == lastToken {
            return Observable<MJResultSimple>.just(.success)
        }
        return storeAndUpload(token: token).simplify()
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
