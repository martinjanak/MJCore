//
//  MJPagingScrollViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import UIKit
import RxSwift

open class MJPagingScrollVC<
    PagingModel: MJPagingModelType,
    View: MJPagingScrollView,
    Model: MJPagingScrollVM<PagingModel>
>: UIViewController {
    
    public let disposeBag = DisposeBag()
    public let ui: View
    private let pagingVC: MJPagingVC<PagingModel>
    public let model: Model
    
    public init() {
        ui = View()
        pagingVC = MJPagingVC<PagingModel>()
        model = Model()
        model.pagingVM = pagingVC.model
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(pagingVC)
        ui.setup(pagingVC.view)
        view = ui
        pagingVC.didMove(toParentViewController: self)
        setup()
        model.initBindings()
        pagingVC.model.initBindings()
        initBindings()
    }
    
    open func setup() {
        // optional override
    }
    
    open func initBindings() {
        // optional override
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
