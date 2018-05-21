//
//  Enum+String.swift
//  MJCore
//
//  Created by Martin Janák on 21/05/2018.
//

import Foundation

public enum MJEnumError: Error {
    case rawValueMismatch
}

extension RawRepresentable {
    public static func create(_ rawValue: RawValue) throws -> Self {
        if let value = Self.init(rawValue: rawValue) {
            return value
        } else {
            throw MJEnumError.rawValueMismatch
        }
    }
}
