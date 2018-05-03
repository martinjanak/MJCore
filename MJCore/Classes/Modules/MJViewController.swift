//
//  MJViewController.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import UIKit

open class MJViewController<View: MJView>: UIViewController {
    
    public let ui: View
    
    init() {
        ui = View()
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        ui.setup()
        view = ui
        setup()
        setupBindings()
    }
    
    open func setup() {
        // optional override
    }
    
    open func setupBindings() {
        // optional override
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
