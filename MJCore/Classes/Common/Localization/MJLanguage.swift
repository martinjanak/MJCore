//
//  MJLanguage.swift
//  MJCore
//
//  Created by Martin Janák on 14/07/2018.
//

import Foundation

public enum MJLanguage: String {
    
    case chinese = "zh"
    case spanish = "es"
    case english = "en"
    case hindi = "hi"
    case arabic = "ar"
    case portuguese = "pt"
    case russian = "ru"
    case japanese = "ja"
    case german = "de"
    case french = "fr"
    case turkish = "tr"
    case italian = "it"
    case polish = "pl"
    case ukrainian = "uk"
    case dutch = "nl"
    case hungarian = "hu"
    case greek = "el"
    case czech = "cs"
    case swedish = "sv"
    case belarusian = "be"
    case slovak = "sk"
    
    public static var current: MJLanguage? {
        if let preferred = Locale.preferredLanguages.first {
            let code = String(preferred.split(separator: "-")[0])
            return MJLanguage(rawValue: code)
        } else {
            return nil
        }
    }
    
    public static var all: [MJLanguage] {
        return [
            .chinese,
            .spanish,
            .english,
            .hindi,
            .arabic,
            .portuguese,
            .russian,
            .japanese,
            .german,
            .french,
            .turkish,
            .italian,
            .polish,
            .ukrainian,
            .dutch,
            .hungarian,
            .greek,
            .czech,
            .swedish,
            .belarusian,
            .slovak
        ]
    }
}
