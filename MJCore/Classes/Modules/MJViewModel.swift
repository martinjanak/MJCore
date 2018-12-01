//
//  MJViewModel.swift
//  MJCore
//
//  Created by Martin Janák on 08/07/2018.
//

import RxSwift
import RxCocoa

public protocol MJViewModel: class {
    func initBindings()
}
