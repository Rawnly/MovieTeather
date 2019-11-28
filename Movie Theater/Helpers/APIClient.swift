//
//  APIClient.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation

struct TMDBApi {
    private let apiKey: String
    private let baseURL: String = "https://api.themoviedb.org/3"
    
    init(_ apiKey: String) {
        self.apiKey = apiKey
    }
    
    enum Endpoint {
        case popularMovies
        case movieDetail(id: Int)
        case searchMovie(query: String)
    }
        
    private func endpointToURL(_ endpoint: Endpoint, page: Int = 1) -> URL? {
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.host = URL(string: baseURL)!.host
        urlComponents.path = "/3"
                
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "api_key", value: apiKey)
        ]
        
        switch endpoint {
        case .searchMovie(query: let query):
            urlComponents.path += "/search/movie"
            urlComponents.queryItems?.append(.init(name: "query", value: query))
        case .popularMovies:
            urlComponents.path += "/movie/popular"
        case .movieDetail(id: let id):
            urlComponents.path += "/movie/\(id)"
        }
        
        return urlComponents.url
    }
    
    func get<T: Decodable>(_ endpoint: Endpoint, page: Int = 1) -> T? {
        guard let url = endpointToURL(endpoint, page: page) else { return nil }
                
        do {
            return try Network.shared.fetchSync(url: url.absoluteString)
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }
}
