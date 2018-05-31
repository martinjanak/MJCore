//
//  MJViewController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

open class MJViewController<View: UIView>: UIViewController {
    
    public let ui: View
    public var disposeBag: DisposeBag?
    
    public init() {
        ui = View()
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
//        ui.setup()
        view = ui
        setup()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initBindings()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = nil
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
