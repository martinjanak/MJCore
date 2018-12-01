//
//  MJLocalNotification.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UserNotifications
import RxSwift

public protocol MJLocalNotifications {
    var id: String { get }
    var title: String { get }
    var body: String { get }
    var trigger: UNNotificationTrigger { get }
}

extension MJLocalNotifications {
    
    public func createTimeTrigger(hour: Int, minute: Int) -> UNCalendarNotificationTrigger {
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        return UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: true
        )
    }
    
}
