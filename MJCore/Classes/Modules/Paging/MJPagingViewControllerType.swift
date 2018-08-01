//
//  MJPageModelPairable.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import Foundation

public protocol MJPagingViewControllerType: class {
    var uniqueId: String { get }
    static var key: String { get }
}
