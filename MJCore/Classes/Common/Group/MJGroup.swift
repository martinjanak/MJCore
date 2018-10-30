//
//  MJGroup.swift
//  MJCore
//
//  Created by Martin Janák on 28/10/2018.
//

import RxSwift

public class MJGroup<Element: MJGroupElementType> {
    
    private let queue = DispatchQueue(
        label: "Group",
        qos: .userInitiated
    )
    
    private var elements: [Element]?
    
    private let changeSubject = PublishSubject<MJGroupChange<Element>>()
    public lazy var change = changeSubject.asObservable()
    
    public init() { }
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
    
    public func update(_ newElements: [Element]) {
        queue.async {
            guard let elements = self.elements else {
                self.elements = newElements
                self.changeSubject.onNext(.initialization(elements: newElements))
                return
            }
            if let index = elements.getCylicPermutationIndex(of: newElements) {
                if index > 0 {
                    self.changeSubject.onNext(.cyclicPermutation(index: index))
                }
            } else {
                let operations = elements.lcsOperations(with: newElements)
                self.changeSubject.onNext(.model(operations: operations))
            }
            self.elements = newElements
        }
    }
    
    // MARK: Operations
    
    public func initialize(elements: [Element]) {
        queue.async {
            self.elements = elements
            self.changeSubject.onNext(.initialization(elements: elements))
        }
    }
    
    public func cyclicPermutate(index: Int) {
        queue.async {
            guard let elements = self.elements else {
                return
            }
            guard 0 < index, index < elements.count else { return }
            let newElements = Array(elements[index...(elements.count-1)])
                + Array(elements[0...(index-1)])
            self.elements = newElements
            self.changeSubject.onNext(.cyclicPermutation(index: index))
        }
    }
    
    public func update(element: Element) {
        queue.async {
            guard var elements = self.elements else { return }
            let indexOptional = elements.firstIndex { $0.uniqueIdType == element.uniqueIdType }
            guard let index = indexOptional else { return }
            
            if elements[index].updateSignature != element.updateSignature {
                elements[index] = element
                let operations = MJGroupModelOperations(
                    inserts: [MJGroupElementOperation<Element>](),
                    deletes: [MJGroupElementOperation<Element>](),
                    updates: [
                        MJGroupElementOperation<Element>(model: element, index: index)
                    ]
                )
                self.changeSubject.onNext(.model(operations: operations))
            }
        }
    }
    
}
