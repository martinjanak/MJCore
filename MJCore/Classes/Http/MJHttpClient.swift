//
//  MJHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation
import RxSwift

public typealias MJHttpHandler = (MJResult<Data>) -> Void
public typealias MJBaseHttpRequest = (@escaping MJHttpHandler) -> Void
public typealias MJHttpResponse = Observable<MJResult<Data>>
public typealias MJHttpRequest = () -> MJHttpResponse

public final class MJHttpClient<Endpoint: MJHttpEndpoints>: MJHttpClientAny<Endpoint> {
    
    private let session: URLSession
    private let urlClosure: ((String) -> String?)?
    
    public init(
        sessionConfig: URLSessionConfiguration? = nil,
        urlClosure: ((String) -> String?)? = nil
    ) {
        if let sessionConfig = sessionConfig {
            session = URLSession(configuration: sessionConfig)
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30
            sessionConfig.timeoutIntervalForResource = 30
            session = URLSession(configuration: sessionConfig)
        }
        self.urlClosure = urlClosure
    }
    
    @discardableResult
    public override func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        return Observable.create { observer in
            DispatchQueue.global(qos: .userInitiated).async {
                self.sendRequestSync(endpoint) { response in
                    observer.onNext(response)
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    public func getRequest(_ endpoint: Endpoint) -> MJHttpRequest {
        return { [weak self] in
            return Observable.create { observer in
                DispatchQueue.global(qos: .userInitiated).async {
                    guard let `self` = self else {
                        observer.onNext(
                            .failure(error: MJObservableError.none)
                        )
                        observer.onCompleted()
                        return
                    }
                    self.sendRequestSync(endpoint) { response in
                        observer.onNext(response)
                        observer.onCompleted()
                    }
                }
                return Disposables.create()
            }
        }
    }
    
    public func getBaseRequest(_ endpoint: Endpoint) -> MJBaseHttpRequest {
        return { [weak self] handler in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let `self` = self else {
                    handler(.failure(error: MJObservableError.none))
                    return
                }
                self.sendRequestSync(endpoint) { response in
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
        
        var url = endpoint.domainUrl
        if let urlClosure = urlClosure {
            guard let urlAdjusted = urlClosure(url) else {
                handler(
                    .failure(error: MJHttpError.invalidUrl)
                )
                return
            }
            url = urlAdjusted
        }
        url = url + endpoint.path
        
        let httpHelper = MJHttpHelper()
        guard let request = httpHelper.createRequest(
            url: url,
            method: endpoint.method,
            data: data
        ) else {
            handler(
                .failure(error: MJHttpError.invalidUrl)
            )
            return
        }
        
        httpHelper.send(session: session, request: request, handler: handler)
    }
    
}

open class MJHttpClientAny<Endpoint: MJHttpEndpoints>: MJHttpClientProtocol {
    public typealias EndpointType = Endpoint
    
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        return .just(MJResult {
            return try MJson().serialize()
        })
    }
}

public protocol MJHttpClientProtocol {
    associatedtype EndpointType: MJHttpEndpoints
    func sendRequest(_ endpoint: EndpointType) -> MJHttpResponse
}
