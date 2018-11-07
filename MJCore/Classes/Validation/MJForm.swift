//
//  MJForm.swift
//  MJCore
//
//  Created by Martin Janák on 15/07/2018.
//

import RxSwift
import RxCocoa

public final class MJForm {
    
    private var disposeBag: DisposeBag?
    private var inputs = [MJValidable]()
    public let isValid = BehaviorRelay<Bool>(value: false)
    
    public init() { }
    
    public func createInput<Value>(
        value: Value,
        validator: @escaping (Value?) -> Bool,
        notValidMessage: String? = nil
    ) -> MJFormInput<Value> {
        let formInput = MJFormInput<Value>(
            value: value,
            validator: validator,
            notValidMessage: notValidMessage
        )
        inputs.append(formInput)
        bindIsValid()
        return formInput
    }
    
    public func createInput(
        value: String,
        validator: MJStringValidator,
        notValidMessage: String? = nil
    ) -> MJFormInput<String> {
        let formInput = MJFormInput<String>(
            value: value,
            validator: validator,
            notValidMessage: notValidMessage
        )
        inputs.append(formInput)
        bindIsValid()
        return formInput
    }
    
    private func bindIsValid() {
        disposeBag = DisposeBag()
        Observable.combineLatest(inputs.map { $0.isValid.asObservable() })
            .map { $0.reduce(true, { $0 && $1 }) }
            .bind(to: isValid)
            .disposed(by: disposeBag!)
    }
    
}
