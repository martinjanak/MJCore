//
//  MJSmartViewComponent.swift
//  MJCore
//
//  Created by Martin Janák on 04/12/2018.
//

import UIKit
import RxSwift

open class MJSmartViewComponent<ViewModel>: MJViewComponent {
    
    public let disposeBag = DisposeBag()
    
    open func initBindings(viewModel: ViewModel) {
        fatalError("initBindings(viewModel:) has not been implemented")
    }
    
}
