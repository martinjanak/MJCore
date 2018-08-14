//
//  UIViewController+ShowAlert.swift
//  MJCore
//
//  Created by Martin Janák on 14/08/2018.
//

import UIKit
import RxSwift

extension MJViewController {
    
    public func showAlert(
        title: String,
        message: String,
        buttonTitle: String = "OK"
    ) -> Observable<Void> {
        return Observable.create { observer in
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: .alert
                )
                let ok = UIAlertAction(title: buttonTitle, style: .default) { _ in
                    observer.onNext(())
                    observer.onCompleted()
                }
                alert.addAction(ok)
                self.present(alert, animated: true, completion: nil)
            }
            return Disposables.create()
        }
    }
    
}
