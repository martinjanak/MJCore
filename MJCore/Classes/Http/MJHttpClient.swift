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
    
    public func sendRequest(_ endpoint: Endpoint) -> Observable<MJResult<Data>> {
        
        guard MJReachability.status != .notReachable else {
            return Observable<MJResult<Data>>.just(
                .failure(error: MJHttpError.noConnection)
            )
        }
        
        let subject = PublishSubject<MJResult<Data>>()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let url = URL(string: "\(endpoint.domainUrl)\(endpoint.path)") else {
                subject.onNext(
                    .failure(error: MJHttpError.invalidUrl)
                )
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method.rawValue
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
            
            if let authorizationClosure = self.authorizationClosure {
                guard authorizationClosure(&request) else {
                    subject.onNext(
                        .failure(error: MJHttpError.couldNotAuthorizeRequest)
                    )
                    return
                }
            }
            
            do {
                let data = try endpoint.getPayloadData()
                if data != nil {
                    request.httpBody = data
                }
            } catch let error {
                subject.onNext(
                    .failure(error: error)
                )
                return
            }
            
            self.dataTask(request: request, subject: subject)
        }
        return subject.asObservable()
    }
    
    private func dataTask(request: URLRequest, subject: PublishSubject<MJResult<Data>>) {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                let nserror = error as NSError
                if nserror.domain == NSURLErrorDomain,
                    nserror.code == -1001 {
                    subject.onNext(.failure(error: MJHttpError.timedOut))
                } else {
                    subject.onNext(.failure(error: error))
                }
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode < 200 || statusCode > 299 {
                    subject.onNext(
                        .failure(error: MJHttpError.http(statusCode: statusCode))
                    )
                    return
                }
            }
            
            guard let data = data else {
                subject.onNext(
                    .failure(error: MJHttpError.noDataReturned)
                )
                return
            }
            
            subject.onNext(.success(value: data))
        }
        
        task.resume()
    }
    
}
