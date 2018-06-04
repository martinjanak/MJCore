//
//  MJRemoteNotificationService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UIKit
import RxSwift

public enum MJRemoteNotificationError: Error {
    case alreadyRegistered
}

open class MJRemoteNotificationService {
    
    public typealias Payload = [AnyHashable: Any]
    
    public init() { }
    
    open func getToken() -> String? {
        fatalError("getToken() has not been implemented")
    }
    
    open func storeAndUpload(token: String) -> MJHttpResponse {
        fatalError("storeAndUpload(token:) has not been implemented")
    }
    
    open func deleteAndRevoke(token: String) -> MJHttpResponse {
        fatalError("deleteAndRevoke(token:) has not been implemented")
    }
    
    open func didReceive(
        payload: Payload,
        completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        fatalError("didReceive(payload:,completionHandler:) has not been implemented")
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
            return .just(
                .failure(error: MJRemoteNotificationError.alreadyRegistered)
            )
        }
        
        return storeAndUpload(token: token).simplify()
    }

}
