//
//  Network.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation


class Network {
    static var shared: Network = Network()
    
    enum HTTPMethod: String {
        case GET = "GET",
        get
        case POST = "POST",
        post
        case PUT = "PUT",
        put
        case DELETE = "DELETE",
        del
    }
    
    enum NetworkError: Error {
        case urlError
        case dataError
        case decodeError(Error)
        case networkError(URLResponse, Error)
    }
    
    func fetch<T: Decodable>(url: String, method: HTTPMethod = .GET, headers: [String: String] = [:], payload: [String: Any]? = nil) throws -> T {
        guard let url = URL(string: url) else {
            throw NetworkError.urlError
        }
        
        var req = URLRequest(url: url);
        req.httpMethod = method.rawValue
        req.url = url;
        req.cachePolicy = .reloadIgnoringLocalCacheData
        
        for (key, value) in headers {
            req.setValue(value, forHTTPHeaderField: key)
        }
        
        if let payload = payload {
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: payload, options: .sortedKeys)
            } catch let e {
                throw NetworkError.decodeError(e);
            }
        }
        
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: req) { (d: Data?, r: URLResponse?, e: Error?) -> Void in
            data = d
            error = e
            response = r
            
            semaphore.signal()
            }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = error, let response = response {
            throw NetworkError.networkError(response, error)
        }
        
        guard data != nil else {
            throw NetworkError.dataError;
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data!) as T
        } catch let error {
            throw NetworkError.decodeError(error);
        }
    }
    
    func fetch<T: Decodable>(url: String) throws -> T {
        guard let u = URL(string: url) else {
            throw NetworkError.urlError;
        }
        
        var request = URLRequest(url: u);
        request.httpMethod = HTTPMethod.GET.rawValue;
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try self.fetch(request: request)
    }
    
    func fetch<T: Decodable>(request req: URLRequest) throws -> T {
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: req) { (d, r, e) in
            data = d
            error = e
            response = r
            
            semaphore.signal()
            }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = error, let response = response {
            throw NetworkError.networkError(response, error);
        }
        
        guard data != nil else {
            throw NetworkError.dataError
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data!) as T
        } catch let error {
            throw NetworkError.decodeError(error);
        }
    }
    
    func fetchSync<T: Decodable>(url: String) throws -> T? {
        var data: Data?
        var error: Error?
        var response: URLResponse?
        
        guard let url = URL(string: url) else {
            throw NetworkError.urlError
        }
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (d, r, e) in
            data = d
            error = e
            response = r
            
            semaphore.signal()
            }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = error, let response = response {
            throw NetworkError.networkError(response, error);
        }
        
        guard data != nil else {
            throw NetworkError.dataError
        }
        
        return JSONDecoder().easyDecode(data!)
    }
    
    
    
    func getData(from url: URL) -> Result<Data, NetworkError> {
        var data: Data?
        var error: Error?
        var response: HTTPURLResponse?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        URLSession.shared.dataTask(with: url) { (d, r, e) in
            data = d
            error = e
            response = r as? HTTPURLResponse
                        
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .distantFuture)
        
        if let error = error, let response = response {
            return Result<Data, NetworkError>.failure(NetworkError.networkError(response, error))
        }
        
        guard data != nil else {
            return Result<Data, NetworkError>.failure(NetworkError.dataError)
        }
        
        return Result<Data, NetworkError>.success(data!)
    }
}
