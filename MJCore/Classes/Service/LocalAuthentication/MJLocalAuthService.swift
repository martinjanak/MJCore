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
    
    public init() { }
    
    public func biometric(
        reason: String,
        fallBackTitle: String
    ) -> Observable<MJResultSimple> {
        return Observable.create { observer in
        
            let context = LAContext()
            context.localizedFallbackTitle = fallBackTitle
            let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        
            var nsError: NSError?
            guard context.canEvaluatePolicy(policy, error: &nsError) else {
                observer.onNext(
                    .failure(error: self.handleCanEvaluateError(nsError))
                )
                observer.onCompleted()
                return Disposables.create()
            }
            context.evaluatePolicy(policy, localizedReason: reason) { (success, error) in
                if success {
                    observer.onNext(.success)
                } else {
                    observer.onNext(
                        .failure(error: MJLocalAuthError.failedToAuthenticate(error: error))
                    )
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func handleCanEvaluateError(_ error: NSError?) -> MJLocalAuthError {
        guard let error = error else {
            return .cannotEvaluate
        }
        switch error.code {
        case Int(kLAErrorBiometryNotAvailable):
            return .deviceDoesNotSupportBiometry
        case Int(kLAErrorBiometryLockout):
            return .failedTooManyTimes
        case Int(kLAErrorBiometryNotEnrolled):
            return .biometryNotEnrolled
        case Int(kLAErrorPasscodeNotSet):
            return .passcodeNotSet
        default:
            return .cannotEvaluate
        }
    }
    
}
