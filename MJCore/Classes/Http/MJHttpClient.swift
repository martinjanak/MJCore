//
//  MJHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation
import RxSwift

public typealias MJHttpSubject = PublishSubject<MJResult<Data>>
public typealias MJHttpSubjectWithProgress = PublishSubject<MJResultWithProgress<Data, Bool>>
public typealias MJHttpResponse = Observable<MJResult<Data>>
public typealias MJHttpResponseWithProgress = Observable<MJResultWithProgress<Data, Bool>>
public typealias MJHttpRequest = () -> MJHttpResponse

public final class MJHttpClient<Endpoint: MJHttpEndpoints>: MJBaseHttpClient {
    
    @discardableResult
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        
        let subject = MJHttpSubject()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendRequestSync(endpoint, handler: subject.onNext)
        }
        
        return subject.asObservable()
    }
    
    @discardableResult
    public func sendRequestWithProgress(_ endpoint: Endpoint) -> MJHttpResponseWithProgress {
        
        let subject = MJHttpSubjectWithProgress()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.sendRequestSyncWithProgress(
                endpoint,
                handler: { response in
                    switch response {
                    case .success(let data):
                        subject.onNext(.success(value: data))
                    case .failure(let error):
                        subject.onNext(.failure(error: error))
                    }
                },
                sent: {
                    subject.onNext(.progress(value: true))
                }
            )
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
                self.sendRequestSync(endpoint, handler: subject.onNext)
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
                self.sendRequestSync(endpoint, handler: handler)
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
    
    private func sendRequestSyncWithProgress(
        _ endpoint: Endpoint,
        handler: @escaping MJHttpHandler,
        sent: @escaping () -> Void
    ) {
        
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
        
        self.send(request: request, handler: handler, sent: sent)
    }
    
}
