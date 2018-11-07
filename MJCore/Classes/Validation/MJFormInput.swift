//
//  MJValidatedVariable.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import RxSwift
import RxCocoa

public final class MJFormInput<Value>: MJValidable {
    
    private let disposeBag = DisposeBag()
    
    public let variable: BehaviorRelay<Value?>
    public let isValid: BehaviorRelay<Bool>
    public let isDirty: BehaviorRelay<Bool>
    public let validityState: BehaviorRelay<MJValidityState>
    
    private let notValidMessage: String?
    
    init(value: Value, validator: @escaping (Value?) -> Bool, notValidMessage: String? = nil) {
        self.notValidMessage = notValidMessage
        variable = BehaviorRelay<Value?>(value: value)
        isValid = BehaviorRelay<Bool>(value: validator(value))
        isDirty = BehaviorRelay<Bool>(value: false)
        validityState = BehaviorRelay<MJValidityState>(value: .notSpecified)
        bindIsValid(validator)
        bindViewState()
    }
    
    private func bindIsValid(_ validator: @escaping (Value?) -> Bool) {
        variable.asObservable()
            .map(validator)
            .bind(to: isValid)
            .disposed(by: disposeBag)
    }
    
    private func bindViewState() {
        Observable.combineLatest(
            isValid.asObservable(),
            isDirty.asObservable()
        )
            .map { [weak self] (isValid, isDirty) -> MJValidityState in
                if isDirty {
                    return isValid ? .valid : .notValid(self?.notValidMessage)
                } else {
                    return .notSpecified
                }
            }
            .bind(to: validityState)
            .disposed(by: disposeBag)
    }
    
}

extension MJFormInput where Value == String {
    
    convenience init(
        value: String,
        validator: MJStringValidator,
        notValidMessage: String? = nil
    ) {
        self.init(
            value: value,
            validator: validator.closure,
            notValidMessage: notValidMessage
        )
    }
    
}
