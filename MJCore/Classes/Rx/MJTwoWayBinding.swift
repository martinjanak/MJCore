//
//  MJTwoWayBinding.swift
//  MJCore
//
//  Created by Martin Janák on 04/05/2018.
//

import UIKit
import RxCocoa
import RxSwift

infix operator <-> : DefaultPrecedence

public func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument
    
    guard let rangeAll = textInput.textRange(from: start, to: end),
        let text = textInput.text(in: rangeAll) else {
            return nil
    }
    
    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }
    
    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        let endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
            return text
    }
    
    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}

public func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    let bindToUIDisposable = relay.asObservable()
        .bind(to: property)
    let bindToRelay = property
        .subscribe(
            onNext: { [weak relay] value in
                relay?.accept(value)
            },
            onCompleted:  {
                bindToUIDisposable.dispose()
            }
        )
    return Disposables.create(bindToUIDisposable, bindToRelay)
}

public func <-> <T: Equatable>(relayA: BehaviorRelay<T>, relayB: BehaviorRelay<T>) -> Disposable {
    let dA = relayA.asObservable()
        .with(relayB.asObservable())
        .filter { newValue, oldValue in
            return newValue != oldValue
        }
        .map { newValue, _ in
            return newValue
        }
        .bind(to: relayB)
    let dB = relayB.asObservable()
        .with(relayA.asObservable())
        .filter { newValue, oldValue in
            return newValue != oldValue
        }
        .map { newValue, _ in
            return newValue
        }
        .bind(to: relayA)
    return Disposables.create(dA, dB)
}

public func <-> (textField: MJTextField, formInput: MJFormInput<String>) -> Disposable {
    
    let textDisposable = textField.rx.textInput.text <-> formInput.variable
    
    let isDirtyDisposable = textField.didEndEditing
        .bind(onNext: { [weak formInputWeak = formInput] _ in
            formInputWeak?.isDirty.accept(true)
        })
    
    let viewStateDisposable = textField.validityState <-> formInput.validityState
    
    // initial value problem
    DispatchQueue.main.async {
        textField.didBindRelay.accept(())
    }
    
    return Disposables.create(
        textDisposable,
        isDirtyDisposable,
        viewStateDisposable
    )
}
