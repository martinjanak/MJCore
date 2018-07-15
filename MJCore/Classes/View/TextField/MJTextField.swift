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
    
    public var maxCount: Int?
    public var allowedCharacterSet: CharacterSet?
    
    public let viewState = Variable<MJFormInputState>(.none)
    
    public var shouldClear: (UITextField) -> Bool = { _ in true }
    public var shouldReturn: (UITextField) -> Bool = { _ in true }
    
    public var shouldBeginEditing: (UITextField) -> Bool = { _ in true }
    
    private let didBeginEditingSubject = PublishSubject<UITextField>()
    public lazy var didBeginEditing = didBeginEditingSubject.asObservable()
    
    public var shouldEndEditing: (UITextField) -> Bool = { _ in true }
    
    private let didEndEditingSubject = PublishSubject<UITextField>()
    public lazy var didEndEditing = didEndEditingSubject.asObservable()
    
    public init() {
        super.init(frame: .zero)
        delegate = self
        setup()
    }
    
    open func setup() {
        // override
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MJTextField: UITextFieldDelegate {
    
    // MARK: Editing
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return shouldBeginEditing(textField)
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditingSubject.onNext(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return shouldEndEditing(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        didEndEditingSubject.onNext(textField)
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
        return shouldClear(textField)
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return shouldReturn(textField)
    }
    
}
