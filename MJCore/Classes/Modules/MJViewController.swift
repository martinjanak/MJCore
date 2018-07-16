//
//  MJViewController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit
import RxSwift

open class MJViewController<View: MJView, Model: MJViewModel>: UIViewController {
    
    public let ui: View
    public let model: Model
    public let disposeBag = DisposeBag()
    
    public init() {
        ui = View()
        model = Model()
        model.initBindings()
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        beforeViewSetup()
        ui.setup()
        view = ui
        afterViewSetup()
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
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
