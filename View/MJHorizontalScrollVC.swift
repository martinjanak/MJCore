//
//  MJSideScrollVC.swift
//  MJCore
//
//  Created by Martin Janák on 03/07/2018.
//

import UIKit

open class MJHorizontalScrollVC<View: MJHorizontalScrollView>: UIViewController {
    
    public let ui: View
    private let pageVC: MJHorizontalPageVC
    
    public init() {
        ui = View()
        pageVC = MJHorizontalPageVC()
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(pageVC)
        ui.setup(pageVC.view)
        view = ui
        pageVC.didMove(toParentViewController: self)
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
