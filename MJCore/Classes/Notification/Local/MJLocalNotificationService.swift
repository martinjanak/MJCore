//
//  MJLocalNotificationService.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UserNotifications
import RxSwift

public final class MJLocalNotificationService<Notification: MJLocalNotifications> {
    
    public init() { }
    
    public func create(
        notification: Notification
    ) -> Observable<MJResultSimple> {
        
        return requestAuthorization()
            .flatMap({ result -> Observable<MJResultSimple> in
                let subject = PublishSubject<MJResultSimple>()
                switch result {
                case .success:
                    let content = UNMutableNotificationContent()
                    content.title = notification.title
                    content.body = notification.body
                    content.sound = UNNotificationSound.default()
                    
                    let request = UNNotificationRequest(
                        identifier: notification.id,
                        content: content,
                        trigger: notification.trigger
                    )
                    UNUserNotificationCenter
                        .current()
                        .add(request) { error in
                            if let error = error {
                                subject.onNext(.failure(error: error))
                            } else {
                                subject.onNext(.success)
                            }
                    }
                default:
                    return Observable<MJResultSimple>.just(result)
                }
                return subject.asObservable()
            })
    }
    
    public func requestAuthorization() -> Observable<MJResultSimple> {
        let subject = PublishSubject<MJResultSimple>()
        UNUserNotificationCenter
            .current()
            .requestAuthorization(
                options: [.alert, .sound, .badge],
                completionHandler: { (granted, error) in
                    if granted {
                        subject.onNext(.success)
                    } else if let error = error {
                        subject.onNext(.failure(error: error))
                    } else {
                        subject.onNext(
                            .failure(error: MJLocalNotificationError.authNotGranted)
                        )
                    }
            }
        )
        return subject.asObservable()
    }
    
    public func getPendingRequests() -> Observable<[UNNotificationRequest]> {
        let subject = PublishSubject<[UNNotificationRequest]>()
        UNUserNotificationCenter
            .current()
            .getPendingNotificationRequests(completionHandler: { requests in
                subject.onNext(requests)
            })
        return subject.asObservable()
    }
    
    public func removeAllPendingRequests() {
        UNUserNotificationCenter
            .current()
            .removeAllPendingNotificationRequests()
    }
    
    // MARK: Error
    
    public enum MJLocalNotificationError: Error {
        case authNotGranted
    }
    
}
