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

public func <-> <Base: UITextInput>(textInput: TextInput<Base>, variable: Variable<String>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: textInput.text)
    let bindToVariable = textInput.text
        .subscribe(
            onNext: { [weak baseWeak = textInput.base] _ in
                guard let base = baseWeak else {
                    return
                }
                let nonMarkedTextValue = nonMarkedText(base)
                if let nonMarkedTextValue = nonMarkedTextValue,
                    nonMarkedTextValue != variable.value {
                    variable.value = nonMarkedTextValue
                }
            },
            onCompleted: {
                bindToUIDisposable.dispose()
            }
        )
    return Disposables.create(bindToUIDisposable, bindToVariable)
}

public func <-> <T>(property: ControlProperty<T>, variable: Variable<T>) -> Disposable {
    let bindToUIDisposable = variable.asObservable()
        .bind(to: property)
    let bindToVariable = property
        .subscribe(
            onNext: { [weak variableWeak = variable] next in
                variableWeak?.value = next
            },
            onCompleted: {
                bindToUIDisposable.dispose()
            }
        )
    return Disposables.create(bindToUIDisposable, bindToVariable)
}
