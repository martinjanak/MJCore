//
//  MJSectionTableModel.swift
//  MJCore
//
//  Created by Martin Janák on 16/08/2018.
//

import Foundation

public protocol MJSectionTableModel {
    
    associatedtype HeaderModel
    associatedtype ItemModel
    
    var header: HeaderModel { get }
    var items: [ItemModel] { get }
    
}
