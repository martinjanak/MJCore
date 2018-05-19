//
//  Array+MJson.swift
//  MJCore
//
//  Created by Martin Janák on 19/05/2018.
//

import Foundation

extension Array where Element: MJsonSerializable {
    
    public func toJsonArray() -> MJsonArray {
        return self.map({ $0.toJson() })
    }
    
}
