//
//  PhoneTypeUtil.swift
//  MJCore
//
//  Created by Martin Janák on 01/11/2018.
//

import Foundation

public final class Display {
    
    class var hasTopNotch: Bool {
        return (topSafeArea ?? 0) > 20
    }
    
    class var topSafeArea: CGFloat? {
        if #available(iOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top
        }
        return nil
    }
    
    class var bottomSafeArea: CGFloat? {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with home indicator: 34.0 on iPhone X, XS, XS Max, XR.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom
        }
        return nil
    }
    
}
