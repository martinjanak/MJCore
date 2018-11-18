//
//  MJResultViewController.swift
//  MJCore
//
//  Created by Martin Janák on 18/11/2018.
//

import UIKit

open class MJResultViewController<View: MJView, ViewModel: MJViewModel, Result>
    : MJViewController<View, ViewModel> {
    
    public var close: ((Result) -> Void)?
    
}

