//
//  MJCollectionViewCell.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJCollectionViewCell<Model>: UICollectionViewCell {
    
    private let disposeBag = DisposeBag()
    public let model: BehaviorRelay<MJCollectionViewCellModel<Model>?>
    
    override public init(frame: CGRect) {
        self.model = BehaviorRelay<MJCollectionViewCellModel<Model>?>(value: nil)
        super.init(frame: .zero)
        initView()
        initBindings()
    }
    
    open func initView() {
        fatalError("initView() has not been implemented")
    }
    
    private func initBindings() {
        model.asDriver()
            .drive(onNext: { [weak self] model in
                self?.set(model: model)
            })
            .disposed(by: disposeBag)
    }
    
    open func set(model: MJCollectionViewCellModel<Model>?) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
