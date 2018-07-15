//
//  MJValidatedVariable.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import RxSwift

public final class MJFormInput<Value>: MJValidable {
    
    private let disposeBag = DisposeBag()
    
    public let variable: Variable<Value>
    public let isValid: Variable<Bool>
    public let isDirty: Variable<Bool>
    public let viewState: Variable<MJFormInputState>
    
    private let notValidMessage: String?
    
    init(value: Value, validator: @escaping (Value) -> Bool, notValidMessage: String? = nil) {
        self.notValidMessage = notValidMessage
        variable = Variable<Value>(value)
        isValid = Variable<Bool>(validator(value))
        isDirty = Variable<Bool>(false)
        viewState = Variable<MJFormInputState>(.none)
        bindIsValid(validator)
        bindViewState()
    }
    
    private func bindIsValid(_ validator: @escaping (Value) -> Bool) {
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
            .map { [weak self] (isValid, isDirty) -> MJFormInputState in
                if isDirty {
                    return isValid ? .valid : .notValid(self?.notValidMessage)
                } else {
                    return .none
                }
            }
            .bind(to: viewState)
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
