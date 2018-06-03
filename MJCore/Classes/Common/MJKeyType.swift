//
//  MJKeyType.swift
//  MJCore
//
//  Created by Martin Janák on 03/06/2018.
//

import Foundation

public protocol MJKeyType: RawRepresentable where RawValue == String {
    static var all: [Self] { get }
}
