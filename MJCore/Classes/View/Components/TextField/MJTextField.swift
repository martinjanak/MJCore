//
//  MJTextField.swift
//  MJCore
//
//  Created by Martin Janák on 15/07/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJTextField: UITextField {
    
    private let disposeBag = DisposeBag()
    
    public var maxCount: Int?
    public var allowedCharacterSet: CharacterSet?
    
    public let hasSomeText = Variable<Bool>(false)
    public let inEditingState = Variable<Bool>(false)
    public let validityState = Variable<MJValidityState>(.notSpecified)
    
    public var shouldClear: () -> Bool = { true }
    public var shouldReturn: () -> Bool = { true }
    
    public var shouldBeginEditing: () -> Bool = { true }
    
    private let didBeginEditingSubject = PublishSubject<Void>()
    public lazy var didBeginEditing = didBeginEditingSubject.asObservable()
    
    public var shouldEndEditing: () -> Bool = { true }
    
    private let didEndEditingSubject = PublishSubject<Void>()
    public lazy var didEndEditing = didEndEditingSubject.asObservable()
    
    // initial value problem
    internal let didBindSubject = PublishSubject<Void>()
    public lazy var didBind = didBindSubject.asObservable()
    
    public init() {
        super.init(frame: .zero)
        delegate = self
        bindHasSomeText()
        initView()
    }
    
    private func bindHasSomeText() {
        rx.text.asObservable()
            .map { text in
                if let text = text, text.count > 0 {
                    return true
                } else {
                    return false
                }
            }
            .bind(to: hasSomeText)
            .disposed(by: disposeBag)
    }
    
    open func initView() {
        // override
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MJTextField: UITextFieldDelegate {
    
    // MARK: Editing
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing()
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        inEditingState.value = true
        didBeginEditingSubject.onNext(())
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        inEditingState.value = false
        didEndEditingSubject.onNext(())
    }
    
    // MARK: Text
    
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        
        // MARK: Allowed characters
        
        if let allowedCharacterSet = allowedCharacterSet, string.count > 0 {
            let disallowedCharacterSet = allowedCharacterSet.inverted
            guard string.rangeOfCharacter(from: disallowedCharacterSet) == nil else {
                return false
            }
        }
        
        // MARK: Max count
        
        if let maxCount = maxCount {
            let currentText = textField.text ?? ""
            guard let stringRange = Range(range, in: currentText) else { return false }
            let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
            return updatedText.count <= maxCount
        }
        
        return true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return shouldClear()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn()
    }
    
}
