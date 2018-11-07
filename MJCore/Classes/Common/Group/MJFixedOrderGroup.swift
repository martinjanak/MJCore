//
//  MJFixedOrderGroup.swift
//  MJCore
//
//  Created by Martin Janák on 30/10/2018.
//

import RxSwift
import RxCocoa

public class MJFixedOrderGroup<Element: MJGroupElementType> {
    
    private let queue = DispatchQueue(
        label: "Group",
        qos: .userInitiated
    )
    
    private var elements: [Element]?
    
    private let changeRelay = PublishRelay<MJFixedOrderGroupChange<Element>>()
    public lazy var change = changeRelay.asObservable()
    
    public init() { }
    
    public func update(_ newElements: [Element]) {
        queue.async {
            guard let elements = self.elements else {
                self.elements = newElements.sorted { $0.uniqueIdType < $1.uniqueIdType }
                self.changeRelay.accept(.initialization(elements: newElements))
                return
            }
            let newElementsSorted = newElements.sorted { $0.uniqueIdType < $1.uniqueIdType }
            let operations = elements.fixedOrderLcsOperations(with: newElementsSorted)
            if operations.hasAny {
                self.changeRelay.accept(.model(operations: operations))
            }
            self.elements = newElements
        }
    }
    
    // MARK: Operations
    
    public func update(element: Element) {
        queue.async {
            guard var elements = self.elements else { return }
            let indexOptional = elements.firstIndex { $0.uniqueIdType == element.uniqueIdType }
            guard let index = indexOptional else { return }
            
            if elements[index].updateSignature != element.updateSignature {
                elements[index] = element
                let operations = MJFixedOrderGroupModelOperations(
                    deletes: [String](),
                    appends: [Element](),
                    updates: [element.uniqueIdType: element]
                )
                self.changeRelay.accept(.model(operations: operations))
            }
        }
    }
    
}
