//
//  MJAuthHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 15/05/2018.
//

import Foundation

public typealias MJBaseHttpRequest = (@escaping MJHttpHandler) -> Void

open class MJBaseAuthHttpClient: MJBaseHttpClient {
    
    private let lock = DispatchQueue(label: "MJAuthHttpClientQueue", qos: .userInitiated)
    private var state: State
    private var resendRequestBuffer = [MJResendRequest]()
    
    private let refreshClosure: MJBaseHttpRequest
    private let addAuthentication: (URLRequest) -> URLRequest?
    
    public init(
        state: State,
        refresh: @escaping MJBaseHttpRequest,
        addAuthentication: @escaping (URLRequest) -> URLRequest?,
        sessionConfig: URLSessionConfiguration? = nil
    ) {
        self.state = state
        self.refreshClosure = refresh
        self.addAuthentication = addAuthentication
        super.init(sessionConfig: sessionConfig)
    }
    
    override public func send(request: URLRequest, handler: @escaping MJHttpHandler) {
        
        var send: Bool = true
        lock.sync {
            switch self.state {
            case .accessValid:
                send = true
            case .accessExpired:
                send = false
                self.resendRequestBuffer.append(
                    MJResendRequest(request: request, handler: handler)
                )
            case .unauthenticated:
                send = false
            }
        }
        
        guard send, let authenticatedRequest = addAuthentication(request) else {
            handler(.failure(error: MJHttpError.couldNotAuthenticateRequest))
            return
        }
        super.send(request: authenticatedRequest) { response in
            if case .failure(let error) = response,
                let httpError = error as? MJHttpError,
                httpError.isUnauthenticated {
                self.onUnauthenticated(request: request, handler: handler)
            } else {
                handler(response)
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
    
    private func refresh() {
        refreshClosure { response in
            self.lock.async {
                if case .success = response {
                    self.state = .accessValid
                    for resendRequest in self.resendRequestBuffer {
                        self.send(request: resendRequest.request, handler: resendRequest.handler)
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

extension MJBaseAuthHttpClient {
    public enum State {
        case unauthenticated
        case accessValid
        case accessExpired
    }
}
