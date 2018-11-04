//
//  MJTableViewCell.swift
//  MJCore
//
//  Created by Martin Janák on 29/07/2018.
//

import UIKit
import RxSwift

open class MJTableViewCell<Model>: UITableViewCell {
    
    private let disposeBag = DisposeBag()
    public let model: Variable<MJTableViewCellModel<Model>?>
    
    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        model = Variable<MJTableViewCellModel<Model>?>(nil)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
    
    open func set(model: MJTableViewCellModel<Model>?) {
        fatalError("init(coder:) has not been implemented")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
