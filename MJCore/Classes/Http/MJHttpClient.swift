//
//  MJHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation
import RxSwift

public typealias MJHttpSubject = PublishSubject<MJResult<Data>>
public typealias MJHttpResponse = Observable<MJResult<Data>>
public typealias MJHttpRequest = () -> MJHttpResponse

public final class MJHttpClient<Endpoint: MJHttpEndpoints>: MJBaseHttpClient {
    
    private let log: MJLogService?
    
    public init(sessionConfig: URLSessionConfiguration? = nil, log: MJLogService? = nil) {
        self.log = log
        super.init(sessionConfig: sessionConfig)
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
    
    public func baseRequest(_ endpoint: Endpoint) -> MJBaseHttpRequest {
        return { [weak self] handler in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let `self` = self else {
                    handler(.failure(error: MJHttpError.clientUnavailable))
                    return
                }
                self.sendRequestSync(endpoint) { response in
                    self.log(response: response, endpoint: endpoint)
                    handler(response)
                }
            }
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
