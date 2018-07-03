//
//  MJHttpAuthClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation
import RxSwift

public final class MJAuthHttpClient<Endpoint: MJHttpEndpoints>: MJHttpClientAny<Endpoint> {
    
    public enum State {
        case unauthenticated
        case accessValid
        case accessExpired
    }
    
    private let session: URLSession
    
    private let lock = DispatchQueue(label: "MJAuthHttpClientQueue")
    private var state: State
    private var resendRequestBuffer = [MJResendRequest]()
    
    private let refreshClosure: MJBaseHttpRequest
    private let authenticateClosure: (URLRequest) -> URLRequest?
    
    public init(
        state: State,
        refresh: @escaping MJBaseHttpRequest,
        authenticateClosure: @escaping (URLRequest) -> URLRequest?,
        sessionConfig: URLSessionConfiguration? = nil
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
    
    private func sendRequestSync(_ endpoint: Endpoint, handler: @escaping MJHttpHandler) {
        
        var data: Data? = nil
        do {
            data = try endpoint.getPayloadData()
        } catch let error {
            handler(.failure(error: error))
            return
        }
        
        let httpHelper = MJHttpHelper()
        guard let request = httpHelper.createRequest(
            url: "\(endpoint.domainUrl)\(endpoint.path)",
            method: endpoint.method,
            data: data
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
    
    public func set(state: State) {
        lock.async {
            self.state = state
        }
    }
    
    public func isAuthenticated() -> Bool {
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
