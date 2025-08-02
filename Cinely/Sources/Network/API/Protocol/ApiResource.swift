//
//  APIResource.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol ApiResource {
    associatedtype ResponseType: Decodable
    var scheme: String { get }
    var host: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var body: Data? { get }
    var query: Query { get }
}

extension ApiResource {
    var scheme: String { "https" }
    var body: Data? { nil }
    
    func urlRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        let queries = self.query.makeQuery()
        
        components.queryItems = queries.reduce(into: [URLQueryItem]()) { origin, next in
            origin.append(URLQueryItem(name: next.key, value: next.value))
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        
        return request
    }
}
