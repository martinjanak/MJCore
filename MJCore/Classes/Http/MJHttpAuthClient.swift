//
//  MJHttpAuthClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation
import RxSwift

public final class MJAuthHttpClient<Endpoint: MJHttpEndpoints>: MJBaseAuthHttpClient {
    
    private let log: MJLogService?
    
    public init(
        state: State,
        refresh: @escaping MJBaseHttpRequest,
        addAuthentication: @escaping (URLRequest) -> URLRequest?,
        sessionConfig: URLSessionConfiguration? = nil,
        log: MJLogService? = nil
    ) {
        self.log = log
        super.init(
            state: state,
            refresh: refresh,
            addAuthentication: addAuthentication,
            sessionConfig: sessionConfig
        )
    }
    
    @discardableResult
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        
        let subject = MJHttpSubject()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendRequestSync(endpoint) { response in
                self.log(response: response, endpoint: endpoint)
                subject.onNext(response)
            }
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
                self.sendRequestSync(endpoint) { response in
                    self.log(response: response, endpoint: endpoint)
                    subject.onNext(response)
                }
            }
            return subject.asObservable()
        }
    }
    
    private func sendRequestSync(_ endpoint: Endpoint, handler: @escaping MJHttpHandler) {
        
        var data: Data? = nil
        do {
            data = try endpoint.getPayloadData()
        } catch let error {
            handler(.failure(error: error))
            return
        }
        
        guard let request = self.createRequest(
            url: "\(endpoint.domainUrl)\(endpoint.path)",
            method: endpoint.method,
            data: data
        ) else {
            handler(
                .failure(error: MJHttpError.invalidUrl)
            )
            return
        }
        
        self.send(request: request, handler: handler)
    }
    
    private func log(response: MJResult<Data>, endpoint: Endpoint) {
        if let log = self.log {
            switch response {
            case .success:
                log.info("Http - \(Endpoint.self)(\(endpoint))", message: "Success")
            case .failure(let error):
                log.error("Http - \(Endpoint.self)(\(endpoint))", message: "\(error)")
            }
        }
    }
    
}

extension MJBaseAuthHttpClient {
    public enum State {
        case unauthenticated
        case accessValid
        case accessExpired
    }
}
