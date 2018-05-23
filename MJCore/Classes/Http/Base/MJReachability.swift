//
//  MJReachability.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation
import SystemConfiguration
import RxSwift

public final class MJReachability {
    
    private let timerInterval: Double
    private var timer: Timer?
    
    private let statusVariable = Variable<Status>(MJReachability.status)
    public lazy var statusObservable = statusVariable.asObservable()
    
    public init(timerInterval: Double = 2) {
        self.timerInterval = timerInterval
    }
    
    public func runTimer() {
        endTimer()
        timer = Timer.scheduledTimer(
            timeInterval: timerInterval,
            target: self,
            selector: #selector(checkReachability),
            userInfo: nil,
            repeats: true
        )
    }
    
    public func endTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc
    private func checkReachability() {
        statusVariable.value = MJReachability.status
    }
    
    public enum Status {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    public static var status: Status {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            return .notReachable
        } else if flags.contains(.isWWAN) == true {
            return .reachableViaWWAN
        } else if flags.contains(.connectionRequired) == false {
            return .reachableViaWiFi
        } else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true)
            && flags.contains(.interventionRequired) == false {
            return .reachableViaWiFi
        } else {
            return .notReachable
        }
    }
    
    deinit {
        endTimer()
    }
    
}
