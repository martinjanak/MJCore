//
//  MJBaseHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation

internal final class MJHttpHelper {
    
    public func createRequest(
        url: String,
        method: MJHttpMethod,
        data: Data?,
        headers: [String: String]? = nil
    ) -> URLRequest? {
        
        guard let url = URL(string: url) else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        
        if let headers = headers {
            for (headerField, value) in headers {
                request.addValue(value, forHTTPHeaderField: headerField)
            }
        }
        
        if let data = data {
            request.httpBody = data
        }
        
        return request
    }
    
    public func send(session: URLSession, request: URLRequest, handler: @escaping MJHttpHandler) {
        guard MJReachability.status != .notReachable else {
            handler(.failure(error: MJHttpError.noConnection))
            return
        }
        dataTask(session: session, request: request, handler: handler)
    }
    
    private func dataTask(session: URLSession, request: URLRequest, handler: @escaping MJHttpHandler) {
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                let nserror = error as NSError
                if nserror.domain == NSURLErrorDomain,
                    nserror.code == -1001 {
                    handler(.failure(error: MJHttpError.timedOut))
                } else {
                    handler(.failure(error: error))
                }
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode < 200 || statusCode > 299 {
                    handler(.failure(error: MJHttpError.http(statusCode: statusCode)))
                    return
                }
            }
            
            guard let data = data else {
                handler(.failure(error: MJHttpError.noDataReturned))
                return
            }
            handler(.success(value: data))
        }
        
        task.resume()
    }
    
}
