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

public func <-> (textField: MJTextField, formInput: MJFormInput<String>) -> Disposable {
    
    let textDisposable = textField.rx.textInput.text <-> formInput.variable
    
    let isDirtyDisposable = textField.didEndEditing
        .bind(onNext: { [weak formInputWeak = formInput] _ in
            formInputWeak?.isDirty.accept(true)
        })
    
    textField.bindValidityState(relay: formInput.validityState)
    
    // initial value problem
    DispatchQueue.main.async {
        textField.didBindRelay.accept(())
    }
    
    return Disposables.create(
        textDisposable,
        isDirtyDisposable
    )
}
