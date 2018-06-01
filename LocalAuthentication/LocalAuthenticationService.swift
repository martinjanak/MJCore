//
//  LocalAuthenticationService.swift
//  MJCore
//
//  Created by Martin Janák on 01/06/2018.
//

import RxSwift
import LocalAuthentication

public protocol HasLocalAuth {
    var localAuth: MJLocalAuthService { get }
}

public enum MJLocalAuthError: Error {
    case cannotEvaluate
    case deviceDoesNotSupportBiometry
    case failedTooManyTimes
    case biometryNotEnrolled
    case passcodeNotSet
    case failedToAuthenticate(error: Error?)
}

public final class MJLocalAuthService {
    
    public func biometric(
        reason: String,
        fallBackTitle: String
    ) -> Observable<MJResultSimple> {
        
        let context = LAContext()
        context.localizedFallbackTitle = fallBackTitle
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
        var nsError: NSError?
        guard context.canEvaluatePolicy(policy, error: &nsError) else {
            return .just(
                .failure(error: handleCanEvaluateError(nsError))
            )
        }
        let subject = PublishSubject<MJResultSimple>()
        context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
            if success {
                subject.onNext(.success)
            } else {
                subject.onNext(
                    .failure(error: MJLocalAuthError.failedToAuthenticate(error: error))
                )
            }
        }
        return subject.asObservable()
    }
    
    private func handleCanEvaluateError(_ error: NSError?) -> MJLocalAuthError {
        guard let error = error else {
            return .cannotEvaluate
        }
        switch error.code {
        case LAError.biometryNotAvailable.rawValue:
            return .deviceDoesNotSupportBiometry
        case LAError.biometryLockout.rawValue:
            return .failedTooManyTimes
        case LAError.biometryNotEnrolled.rawValue:
            return .biometryNotEnrolled
        case LAError.passcodeNotSet.rawValue:
            return .passcodeNotSet
        default:
            return .cannotEvaluate
        }
    }
    
}
