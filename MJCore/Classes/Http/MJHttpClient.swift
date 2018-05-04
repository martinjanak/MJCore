//
//  MJHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 03/05/2018.
//

import Foundation
import RxSwift

public final class MJHttpClient<Endpoint: MJHttpEndpoints> {
    
    private let session: URLSession
    private let authorizationClosure: ((inout URLRequest) -> Bool)?
    
    init(
        sessionConfig: URLSessionConfiguration? = nil,
        authorizationClosure: ((inout URLRequest) -> Bool)? = nil
    ) {
        if let sessionConfig = sessionConfig {
            session = URLSession(configuration: sessionConfig)
        } else {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30
            sessionConfig.timeoutIntervalForResource = 30
            session = URLSession(configuration: sessionConfig)
        }
        self.authorizationClosure = authorizationClosure
    }
    
    public func sendRequest(_ endpoint: Endpoint) -> Observable<MJHttpResponse> {
        
        guard MJReachability.status != .notReachable else {
            return Observable<MJHttpResponse>.just(.noConnection)
        }
        
        let subject = PublishSubject<MJHttpResponse>()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let url = URL(string: "\(endpoint.domainUrl)\(endpoint.path)") else {
                subject.onNext(.errorInvalidUrl)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
            
            if let authorizationClosure = self.authorizationClosure {
                guard authorizationClosure(&request) else {
                    subject.onNext(.errorCouldNotAuthorizeRequest)
                    return
                }
            }
            
            do {
                let data = try endpoint.getPayloadData()
                if data != nil {
                    request.httpBody = data
                }
            } catch let error {
                subject.onNext(.errorCouldNotEncodeData(error: error))
                return
            }
            
            self.dataTask(request: request, subject: subject)
        }
        return subject.asObservable()
    }
    
    private func dataTask(request: URLRequest, subject: PublishSubject<MJHttpResponse>) {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                let nserror = error as NSError
                if nserror.domain == NSURLErrorDomain,
                    nserror.code == -1001 {
                    subject.onNext(.timedOut)
                } else {
                    subject.onNext(.errorSystem(error: error))
                }
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode < 200 || statusCode > 299 {
                    subject.onNext(.errorHttp(statusCode: statusCode))
                    return
                }
            }
            
            guard let data = data else {
                subject.onNext(.errorNoDataReturned)
                return
            }
            
            subject.onNext(.success(data: data))
        }
        
        task.resume()
    }
    
}
