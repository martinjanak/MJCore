//
//  MJModalViewController.swift
//  MJCore
//
//  Created by Martin Janák on 10/07/2018.
//

import UIKit
import RxSwift

open class MJModalViewController<View: MJView, Result>: UIViewController {
    
    public let ui: View
    public var close: ((Result) -> Void)?
    
    public init() {
        ui = View()
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
