//
//  MJHttpAuthClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation
import RxSwift

public enum MJAuthHttpClientState {
    case unauthenticated
    case accessValid
    case accessExpired
}

public final class MJAuthHttpClient<Endpoint: MJHttpEndpoints>: MJAuthHttpClientAny<Endpoint> {
    
    private let session: URLSession
    private let urlClosure: ((String) -> String?)?
    
    private let lock = DispatchQueue(label: "MJAuthHttpClientQueue")
    private var state: MJAuthHttpClientState
    private var resendRequestBuffer = [MJResendRequest]()
    
    private let refreshClosure: MJBaseHttpRequest
    private let authenticateClosure: (URLRequest) -> URLRequest?
    
    public init(
        state: MJAuthHttpClientState,
        refresh: @escaping MJBaseHttpRequest,
        authenticateClosure: @escaping (URLRequest) -> URLRequest?,
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
        self.state = state
        self.refreshClosure = refresh
        self.authenticateClosure = authenticateClosure
        self.urlClosure = urlClosure
    }
    
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
            data: data,
            query: endpoint.query,
            headers: endpoint.additionalHeaders
        ) else {
            handler(
                .failure(error: MJHttpError.invalidUrl)
            )
            return
        }
        
        lock.async {
            if case .accessExpired = self.state {
                self.resendRequestBuffer.append(
                    MJResendRequest(request: request, handler: handler)
                )
            }
            guard
                case .accessValid = self.state,
                let authenticatedRequest = self.authenticateClosure(request)
                else {
                    handler(.failure(error: MJHttpError.couldNotAuthenticateRequest))
                    return
            }
            let httpHelper = MJHttpHelper()
            httpHelper.send(session: self.session, request: authenticatedRequest) { response in
                if case .failure(let error) = response,
                    let httpError = error as? MJHttpError,
                    httpError.isUnauthenticated {
                    self.onUnauthenticated(request: request, handler: handler)
                } else {
                    handler(response)
                }
            }
        }
    }
    
    private func resend(request: URLRequest, handler: @escaping MJHttpHandler) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let authenticatedRequest = self.authenticateClosure(request) else {
                handler(.failure(error: MJHttpError.couldNotAuthenticateRequest))
                return
            }
            let httpHelper = MJHttpHelper()
            httpHelper.send(session: self.session, request: authenticatedRequest) { response in
                if case .failure(let error) = response,
                    let httpError = error as? MJHttpError,
                    httpError.isUnauthenticated {
                    self.onUnauthenticated(request: request, handler: handler)
                } else {
                    handler(response)
                }
            }
        }
    }
    
    private func onUnauthenticated(request: URLRequest, handler: @escaping MJHttpHandler) {
        lock.async {
            switch self.state {
            case .accessValid:
                self.state = .accessExpired
                self.resendRequestBuffer.append(
                    MJResendRequest(request: request, handler: handler)
                )
                self.refresh()
            case .accessExpired:
                self.resendRequestBuffer.append(
                    MJResendRequest(request: request, handler: handler)
                )
            case .unauthenticated:
                handler(.failure(error: MJHttpError.couldNotAuthenticateRequest))
            }
        }
    }
    
    override public func set(state: MJAuthHttpClientState) {
        lock.async {
            self.state = state
        }
    }
    
    override public func isAuthenticated() -> Bool {
        var auth = false
        lock.sync {
            if case .unauthenticated = self.state {
                auth = false
            } else {
                auth = true
            }
        }
        return auth
    }
    
    private func refresh() {
        refreshClosure { response in
            self.lock.async {
                if case .success = response {
                    self.state = .accessValid
                    for resendRequest in self.resendRequestBuffer {
                        self.resend(request: resendRequest.request, handler: resendRequest.handler)
                    }
                } else {
                    self.state = .unauthenticated
                    for resendRequest in self.resendRequestBuffer {
                        resendRequest.handler(.failure(error: MJHttpError.couldNotAuthenticateRequest))
                    }
                }
                self.resendRequestBuffer.removeAll()
            }
        }
    }
    
}

open class MJAuthHttpClientAny<Endpoint: MJHttpEndpoints>: MJAuthHttpClientProtocol {
    public typealias EndpointType = Endpoint
    
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        return .just(MJResult {
            return try MJson().serialize()
        })
    }
    
    public func isAuthenticated() -> Bool {
        return false
    }
    
    public func set(state: MJAuthHttpClientState) { }
    
}

public protocol MJAuthHttpClientProtocol {
    associatedtype EndpointType: MJHttpEndpoints
    func sendRequest(_ endpoint: EndpointType) -> MJHttpResponse
    func isAuthenticated() -> Bool
    func set(state: MJAuthHttpClientState)
}
