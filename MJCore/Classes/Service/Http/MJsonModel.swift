//
//  MJsonModel.swift
//  MJCore
//
//  Created by Martin Janák on 19/05/2018.
//

import Foundation

public protocol MJsonParsable {
    init(json: MJson) throws
}

public protocol MJsonSerializable {
    func toJson() -> MJson
}

public typealias MJsonModel = MJsonParsable & MJsonSerializable
