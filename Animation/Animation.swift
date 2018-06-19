//
//  Animation.swift
//  MJCore
//
//  Created by Martin Janák on 16/06/2018.
//

import UIKit
import RxSwift

extension UIView {
    
    static func anim(duration: TimeInterval, animations: @escaping () -> Void) -> Observable<Bool> {
        return Observable<Bool>.create { observer in
            UIView.animate(
                withDuration: duration,
                animations: animations
            ) { completed in
                observer.onNext(completed)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
}
