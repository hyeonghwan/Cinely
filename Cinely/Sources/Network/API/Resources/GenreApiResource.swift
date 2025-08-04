//
//  GenreResponseDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct GenreApiResource: ApiResource {
    typealias ResponseType = GenreResponseDTO
    
    struct GenreQuery: Query {
        var language: String = "ko-KR"
    }
    
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String = "/3/genre/movie/list"
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    
    init(method: HTTPMethod = .get, query: GenreQuery = GenreQuery()) {
        self.method = method
        self.query = query
    }
}
