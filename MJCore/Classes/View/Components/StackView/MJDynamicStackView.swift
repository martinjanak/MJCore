//
//  StackView.swift
//  MJCore
//
//  Created by Martin Janák on 19/08/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJDynamicStackView<StackModel>: UIStackView {
    
    private typealias CellConstructor = (StackModel) -> (
        ((UIStackView, Int) -> UIView)?
    )
    
    private let disposeBag = DisposeBag()
    public let data = BehaviorRelay(value: [StackModel]())
    private var cellConstructors = [CellConstructor]()
    
    public init() {
        super.init(frame: .zero)
        alignment = .fill
        axis = .vertical
        distribution = .fill
        initView()
        initBindings()
    }
    
    private func initBindings() {
        data.asDriver()
            .drive(onNext: { [weak self] data in
                guard let strongSelf = self else { return }
                strongSelf.removeAllArrangedSubviews()
                for (index, model) in data.enumerated() {
                    for cellConstructor in strongSelf.cellConstructors {
                        if let cellSetup = cellConstructor(model) {
                            let cellView = cellSetup(strongSelf, index)
                            strongSelf.addArrangedSubview(cellView)
                        }
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Homogenous stack
    
    public func register<Cell: MJStackViewCell<StackModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((UIStackView, Int, StackModel, inout Cell) -> Void)? = nil
    ) {
        cellConstructors.append({ cellModel in
            return { stackView, index in
                var cell = Cell()
                cell.model.accept(MJStackViewCellModel(
                    stackView: stackView,
                    index: index,
                    cell: cellModel
                ))
                additionalSetup?(stackView, index, cellModel, &cell)
                return cell
            }
        })
    }
    
    // MARK: Heterogenous stack
    // - CellModel has to implement StackModel protocol or extend StackModel class
    
    public func register<CellModel, Cell: MJStackViewCell<CellModel>>(
        _ cellClass: Cell.Type,
        additionalSetup: ((UIStackView, Int, CellModel, inout Cell) -> Void)? = nil
    ) {
        cellConstructors.append({ stackModel in
            if let cellModel = stackModel as? CellModel {
                return { stackView, index in
                    var cell = Cell()
                    cell.model.accept(MJStackViewCellModel(
                        stackView: stackView,
                        index: index,
                        cell: cellModel
                    ))
                    additionalSetup?(stackView, index, cellModel, &cell)
                    return cell
                }
            } else {
                return nil
            }
        })
    }
    
    open func initView() {
        // override
    }
    
    required public init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
