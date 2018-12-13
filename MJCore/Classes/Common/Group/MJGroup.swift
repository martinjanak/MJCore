//
//  MJGroup.swift
//  MJCore
//
//  Created by Martin Janák on 28/10/2018.
//

import RxSwift
import RxCocoa

public class MJGroup<Element: MJGroupElementType> {
    
    private let semaphore = DispatchSemaphore(value: 1)
    
    private var elements: [Element]?
    private let changeRelay = PublishRelay<MJGroupChange<Element>>()
    
    public init() { }
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
    
    public func update(_ newElements: [Element]) {
        semaphore.wait(); defer { semaphore.signal() }
        
        guard let elements = self.elements else {
            self.elements = newElements
            self.changeRelay.accept(.initialization(elements: newElements))
            return
        }
        if let index = elements.getCylicPermutationIndex(of: newElements) {
            if index > 0 {
                self.changeRelay.accept(.cyclicPermutation(index: index, count: elements.count))
            }
        } else {
            let operations = elements.lcsOperations(with: newElements)
            self.changeRelay.accept(.model(operations: operations))
        }
        self.elements = newElements
    }
    
    // MARK: Operations
    
    public func insert(element: Element, at index: Int) {
        semaphore.wait(); defer { semaphore.signal() }
        guard var elements = self.elements else {
            let newElements = [element]
            self.elements = newElements
            changeRelay.accept(.initialization(elements: newElements))
            return
        }
        guard elements.count > index else {
            return
        }
        elements.insert(element, at: index)
        let operations = MJGroupModelOperations(
            inserts: [
                 MJGroupElementOperation<Element>(model: element, index: index)
            ],
            deletes: [MJGroupElementOperation<Element>](),
            updates: [MJGroupElementOperation<Element>]()
        )
        changeRelay.accept(.model(operations: operations))
    }
    
    public func delete(at index: Int) {
        semaphore.wait(); defer { semaphore.signal() }
        guard var elements = self.elements,
            elements.count > index else {
            return
        }
        let removedElement = elements.remove(at: index)
        let operations = MJGroupModelOperations(
            inserts: [MJGroupElementOperation<Element>](),
            deletes: [
                MJGroupElementOperation<Element>(model: removedElement, index: index)
            ],
            updates: [MJGroupElementOperation<Element>]()
        )
        changeRelay.accept(.model(operations: operations))
    }
    
    public func update(element: Element) {
        semaphore.wait(); defer { semaphore.signal() }
        
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
            self.changeRelay.accept(.model(operations: operations))
        }
    }
    
    public func cyclicPermutate(index: Int) {
        semaphore.wait(); defer { semaphore.signal() }
        
        guard let elements = self.elements else {
            return
        }
        guard 0 < index, index < elements.count else { return }
        let newElements = Array(elements[index...(elements.count-1)])
            + Array(elements[0...(index-1)])
        self.elements = newElements
        self.changeRelay.accept(.cyclicPermutation(index: index, count: elements.count))
    }
    
    public func getElement(at index: Int) -> Element? {
        semaphore.wait(); defer { semaphore.signal() }
        if let elements = elements, elements.count > index {
            return elements[index]
        } else {
            return nil
        }
    }
    
    // MARK: Rx
    
    public func asObservable() -> Observable<MJGroupChange<Element>> {
        semaphore.wait(); defer { semaphore.signal() }
        if let elements = self.elements {
            return changeRelay
                .asObservable()
                .startWith(.initialization(elements: elements))
        } else {
            return changeRelay
                .asObservable()
        }
    }
    
}
