//
//  MJGroup.swift
//  MJCore
//
//  Created by Martin Janák on 28/10/2018.
//

import RxSwift

public protocol MJGroupElementType {
    var uniqueId: String { get }
    var updateSignature: String { get }
}

extension MJGroupElementType {
    
    public var uniqueIdType: String {
        return "\(Self.self)-" + uniqueId
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uniqueIdType == rhs.uniqueIdType
    }
    
    public static func != (lhs: Self, rhs: Self) -> Bool {
        return !(lhs == rhs)
    }
    
    public static func ~~ (lhs: Self, rhs: Self) -> Bool {
        return lhs.updateSignature == rhs.updateSignature
    }
    
    public static func !~ (lhs: Self, rhs: Self) -> Bool {
        return !(lhs ~~ rhs)
    }
    
    public var totalId: String {
        return "\(uniqueIdType)\(updateSignature)"
    }
    
}

public class MJGroup<Element: MJGroupElementType> {
    
    private let queue = DispatchQueue(
        label: "Group",
        qos: .userInitiated
    )
    
    private var elements: [Element]
    
    private let changeSubject = PublishSubject<MJGroupChange<Element>>()
    public lazy var change = changeSubject.asObservable()
    
    public init() {
        elements = [Element]()
    }
    
    public init(_ elements: [Element]) {
        self.elements = elements
    }
    
    public func update(_ newElements: [Element]) {
        queue.async {
            if let index = self.elements.getCylicPermutationIndex(of: newElements) {
                self.changeSubject.onNext(.cyclicPermutation(index: index))
            } else if let transpositions = self.elements.getTranspositions(of: newElements) {
                if transpositions.count == 1 {
                    self.changeSubject.onNext(
                        .transpositon(from: transpositions[0].from, to: transpositions[0].to)
                    )
                } else {
                    self.changeSubject.onNext(.permutation(transpositions))
                }
            } else {
                let operations = self.elements.lcsOperations(with: newElements)
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
    
    public func transpose(from: Int, to: Int) {
        queue.async {
            self.elements.swapAt(from, to)
            self.changeSubject.onNext(.transpositon(from: from, to: to))
        }
    }
    
    public func cyclicPermutate(index: Int) {
        queue.async {
            guard 0 < index, index < self.elements.count else { return }
            let newElements = Array(self.elements[index...(self.elements.count-1)])
                + Array(self.elements[0...(index-1)])
            self.elements = newElements
            self.changeSubject.onNext(.cyclicPermutation(index: index))
        }
    }
    
}


public struct MJGroupElementOperation<Model: MJGroupElementType> {
    public var model: Model
    public var index: Int
}

public enum MJGroupChange<Element: MJGroupElementType> {
    case initialization(elements: [Element])
    case cyclicPermutation(index: Int)
    case transpositon(from: Int, to: Int)
    case permutation([(from: Int, to: Int)])
    case model(operations: MJGroupModelOperations<Element>)
}

public struct MJGroupModelOperations<Element: MJGroupElementType> {
    
    public var inserts: [MJGroupElementOperation<Element>]
    public var deletes: [MJGroupElementOperation<Element>]
    public var updates: [MJGroupElementOperation<Element>]
    
    public var hasAny: Bool {
        return inserts.count + deletes.count + updates.count > 0
    }
    
}

extension MJGroupModelOperations {
    public static func +(
        left: MJGroupModelOperations<Element>,
        right: MJGroupModelOperations<Element>
    ) -> MJGroupModelOperations<Element> {
        return MJGroupModelOperations<Element>(
            inserts: left.inserts + right.inserts,
            deletes: left.deletes + right.deletes,
            updates: left.updates + right.updates
        )
    }
}
