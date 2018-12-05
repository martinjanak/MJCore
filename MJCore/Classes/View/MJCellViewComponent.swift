//
//  MJCellComponent.swift
//  MJCore
//
//  Created by Martin Janák on 01/12/2018.
//

import UIKit
import RxSwift
import RxCocoa

open class MJCellViewComponent<Model>: MJView {
    
    private let disposeBag = DisposeBag()
    public let model: BehaviorRelay<Model?>
    
    required public init(model: Model? = nil) {
        self.model = BehaviorRelay<Model?>(value: model)
        super.init(frame: .zero)
        initView()
        initBindings()
    }
    
    private func initBindings() {
        model.asDriver()
            .drive(onNext: { [weak self] model in
                self?.set(model: model)
            })
            .disposed(by: disposeBag)
    }
    
    open func set(model: Model?) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
