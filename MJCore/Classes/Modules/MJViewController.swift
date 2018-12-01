//
//  MJViewController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

open class MJViewController<View: MJView, ViewModel: MJViewModel>: UIViewController {
    
    public let ui: View
    public let viewModel: ViewModel
    public let disposeBag = DisposeBag()
    
    private(set) public var endEditingTapGR: UITapGestureRecognizer?
    
    public init(viewModel: ViewModel) {
        ui = View()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        beforeViewSetup()
        ui.initView()
        view = ui
        afterViewSetup()
        viewModel.initBindings()
        initBindings()
    }
    
    open func beforeViewSetup() {
        // optional override
    }
    
    open func afterViewSetup() {
        // optional override
    }
    
    open func initBindings() {
        // optional override
    }
    
    public var endsEditingOnTap: Bool = false {
        didSet {
            if endsEditingOnTap {
                endEditingTapGR = UITapGestureRecognizer(
                    target: view,
                    action: #selector(view.endEditing)
                )
                view.addGestureRecognizer(endEditingTapGR!)
            } else {
                if let endEditingTapGR = endEditingTapGR {
                    view.removeGestureRecognizer(endEditingTapGR)
                }
            }
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
