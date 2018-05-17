//
//  MJHttpAuthClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation
import RxSwift

public final class MJAuthHttpClient<Endpoint: MJHttpEndpoints>: MJBaseAuthHttpClient {
    
    @discardableResult
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        
        let subject = MJHttpSubject()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendRequestSync(endpoint, subject: subject)
        }
        
        return subject.asObservable()
    }
    
    public func request(_ endpoint: Endpoint) -> MJHttpRequest {
        return { [weak self] in
            let subject = MJHttpSubject()
            DispatchQueue.global(qos: .userInitiated).async {
                guard let `self` = self else {
                    subject.onNext(
                        .failure(error: MJHttpError.clientUnavailable)
                    )
                    return
                }
                self.sendRequestSync(endpoint, subject: subject)
            }
            return subject.asObservable()
        }
    }
    
    private func sendRequestSync(_ endpoint: Endpoint, subject: MJHttpSubject) {
        
        var data: Data? = nil
        do {
            data = try endpoint.getPayloadData()
        } catch let error {
            subject.onNext(.failure(error: error))
            return
        }
        
        guard let request = self.createRequest(
            url: "\(endpoint.domainUrl)\(endpoint.path)",
            method: endpoint.method,
            data: data
        ) else {
            subject.onNext(
                .failure(error: MJHttpError.invalidUrl)
            )
            return
        }
        
        self.send(request: request, handler: subject.onNext)
    }
    
}

extension MJBaseAuthHttpClient {
    public enum State {
        case unauthenticated
        case accessValid
        case accessExpired
    }
}
