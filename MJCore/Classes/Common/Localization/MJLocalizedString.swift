//
//  MJLocalizedString.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import Foundation

public protocol MJLocalizedString {
    var defaultLanguage: MJLanguage { get }
    var translation: [MJLanguage: String] { get }
    func forceLanguage() -> MJLanguage?
}

extension MJLocalizedString {
    
    public func forceLanguage() -> MJLanguage? {
        return nil
    }
    
    public func loc() -> String {
        if let forceLanguage = self.forceLanguage() {
            if let translation = self.translation[forceLanguage] {
                return translation
            } else {
                return "???"
            }
        }
        if let language = MJLanguage.current,
            let translation = self.translation[language] {
            return translation
        } else if let translation = self.translation[self.defaultLanguage] {
            return translation
        } else {
            return "???"
        }
    }
    
}
