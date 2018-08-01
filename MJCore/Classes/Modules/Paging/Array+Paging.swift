//
//  Array+Paging.swift
//  MJCore
//
//  Created by Martin Janák on 01/08/2018.
//

import Foundation

extension Array where Element: MJPagingModelType {
    
    public func index(of pageViewController: MJPagingViewControllerType) -> Int? {
        for i in 0..<self.count {
            if pageViewController.uniqueId == self[i].uniqueId {
                return i
            }
        }
        return nil
    }
    
}
