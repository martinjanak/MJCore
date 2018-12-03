//
//  MJPopoverViewController.swift
//  MJCore
//
//  Created by Martin Janák on 30/11/2018.
//

import UIKit
import RxSwift
import Stevia

open class MJPopoverViewController<View: MJView, ViewModel: MJViewModel, Result>: UIViewController {
    
    public var close: ((Result) -> Void)?
    internal var animated: Bool = true
    
    public let popover: View
    public let viewModel: ViewModel
    public let disposeBag = DisposeBag()
    
    public let sourceViewBounds: CGRect
    public let direction: UIPopoverArrowDirection
    private let overlayColor: UIColor
    
    public init(
        viewModel: ViewModel,
        sourceView: UIView,
        direction: UIPopoverArrowDirection = .any,
        overlayColor: UIColor = .clear
    ) {
        self.sourceViewBounds = sourceView.convert(sourceView.bounds, to: nil)
        self.direction = direction
        self.overlayColor = overlayColor
        popover = View()
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        beforeViewSetup()
        popover.initView()
        setupView()
        afterViewSetup()
        viewModel.initBindings()
        initBindings()
    }
    
    private func setupView() {
        view.backgroundColor = overlayColor
        view.sv(popover)
        // todo - based on direction
        popover
            .top(sourceViewBounds.maxY)
            .bottom(>=0)
            .right(>=0)
            .left(>=0)
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
