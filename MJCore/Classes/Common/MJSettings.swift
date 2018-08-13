//
//  MJSettings.swift
//  MJCore
//
//  Created by Martin Janák on 13/08/2018.
//

import Foundation

public final class MJSettings {
    
    public static let shared = MJSettings()
    
    public var debug = false
    
    private init() { }
    
}
