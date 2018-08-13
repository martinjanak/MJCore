//
//  MJDebug.swift
//  MJCore
//
//  Created by Martin Janák on 13/08/2018.
//

import Foundation

internal func debug(_ log: String) {
    if MJSettings.shared.debug {
        print(log)
    }
}
