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
    
    public let hasSomeText = BehaviorRelay<Bool>(value: false)
    public let inEditingState = BehaviorRelay<Bool>(value: false)
    public let validityState = BehaviorRelay<MJValidityState>(value: .notSpecified)
    
    public var shouldClear: () -> Bool = { true }
    public var shouldReturn: () -> Bool = { true }
    
    public var shouldBeginEditing: () -> Bool = { true }
    
    private let didBeginEditingRelay = PublishRelay<Void>()
    public lazy var didBeginEditing = didBeginEditingRelay.asObservable()
    
    public var shouldEndEditing: () -> Bool = { true }
    
    private let didEndEditingRelay = PublishRelay<Void>()
    public lazy var didEndEditing = didEndEditingRelay.asObservable()
    
    // initial value problem
    internal let didBindRelay = PublishRelay<Void>()
    public lazy var didBind = didBindRelay.asObservable()
    
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
        inEditingState.accept(true)
        didBeginEditingRelay.accept(())
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing()
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        inEditingState.accept(false)
        didEndEditingRelay.accept(())
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
