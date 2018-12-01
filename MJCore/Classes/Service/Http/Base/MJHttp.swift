//
//  MJBaseHttpClient.swift
//  MJCore
//
//  Created by Martin Janák on 07/05/2018.
//

import Foundation

public final class MJHttp {
    
    private init() { }
    
    public static func createRequest(endpoint: MJHttpEndpoint) -> MJResult<URLRequest> {
        
        let urlString = endpoint.domainUrl + endpoint.path
        
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
        
        return .success(value: request)
    }
    
    public static func send(_ request: URLRequest, with session: URLSession, handler: @escaping MJHttpHandler) {
        guard MJReachability.status != .notReachable else {
            handler(.failure(error: MJHttpError.noConnection))
            return
        }
        dataTask(session: session, request: request, handler: handler)
    }
    
    private static func dataTask(session: URLSession, request: URLRequest, handler: @escaping MJHttpHandler) {
        
        debug("[http]: Request \(request.httpMethod ?? "No Method") \(request.url?.absoluteString ?? "No URL")")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                let nserror = error as NSError
                if nserror.domain == NSURLErrorDomain,
                    nserror.code == -1001 {
                    handler(.failure(error: MJHttpError.timedOut))
                } else {
                    handler(.failure(error: error))
                }
                debug("[http]: System error: \(error)")
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode < 200 || statusCode > 299 {
                    debug("[http]: Response error status code: \(statusCode)")
                    handler(.failure(error: MJHttpError.http(statusCode: statusCode, data: data)))
                    return
                }
            }
            
            guard let data = data else {
                debug("[http]: Response error: no data returned")
                handler(.failure(error: MJHttpError.noDataReturned))
                return
            }
            debug("[http]: Response OK")
            handler(.success(value: data))
        }
        
        task.resume()
    }
    
}
