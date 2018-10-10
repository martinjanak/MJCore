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

public final class MJHttpClient<Endpoint: MJHttpEndpoint>: MJHttpClientAny<Endpoint> {
    
    private let session: URLSession
    
    private let basePathClosure: ((Endpoint) -> String?)?
    private let requestClosure: ((Endpoint, URLRequest) -> URLRequest)?
    
    public init(
        sessionConfig: URLSessionConfiguration? = nil,
        basePathClosure: ((Endpoint) -> String?)? = nil,
        requestClosure: ((Endpoint, URLRequest) -> URLRequest)? = nil
    ) {
        if let sessionConfig = sessionConfig {
            session = URLSession(configuration: sessionConfig)
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30
            sessionConfig.timeoutIntervalForResource = 30
            session = URLSession(configuration: sessionConfig)
        }
        self.basePathClosure = basePathClosure
        self.requestClosure = requestClosure
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
        switch createRequest(endpoint) {
        case .success(let request):
            MJHttp.send(request, with: session, handler: handler)
        case .failure(let error):
            handler(.failure(error: error))
        }
    }
    
    private func createRequest(_ endpoint: Endpoint) -> MJResult<URLRequest> {
        
        var urlString = endpoint.domainUrl
        if let basePathClosure = basePathClosure,
            let basePath = basePathClosure(endpoint) {
            urlString = urlString + basePath
        }
        urlString = urlString + endpoint.path
        
        guard var urlComponents = URLComponents(string: urlString) else {
            return .failure(error: MJHttpError.invalidUrlComponents)
        }
        
        // MARK: Query
        
        var queryItems: [URLQueryItem]? = nil
        if let query = endpoint.query, query.count > 0 {
            queryItems = [URLQueryItem]()
            for (key, value) in query {
                queryItems!.append(URLQueryItem(name: key, value: value))
            }
        }
        urlComponents.queryItems = queryItems
        
        // MARK: Url
        
        guard let url = urlComponents.url else {
            return .failure(error: MJHttpError.invalidUrl)
        }
        
        var request = URLRequest(url: url)
        
        // MARK: Method
        
        request.httpMethod = endpoint.method.rawValue
        
        // MARK: Headers
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        
        if let headers = endpoint.headers {
            for (headerField, value) in headers {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        
        // MARK: Data
        
        var data: Data? = nil
        do {
            data = try endpoint.getPayloadData()
        } catch let error {
            return .failure(error: error)
        }
        
        if let data = data {
            request.httpBody = data
        }
        
        if let requestClosure = requestClosure {
            request = requestClosure(endpoint, request)
        }
        
        return .success(value: request)
    }
    
}

open class MJHttpClientAny<Endpoint: MJHttpEndpoint>: MJHttpClientProtocol {
    public typealias EndpointType = Endpoint
    
    public func sendRequest(_ endpoint: Endpoint) -> MJHttpResponse {
        return .just(MJResult {
            return try MJson().serialize()
        })
    }
}

public protocol MJHttpClientProtocol {
    associatedtype EndpointType: MJHttpEndpoint
    func sendRequest(_ endpoint: EndpointType) -> MJHttpResponse
}
