//
//  MovieSearchApiResource.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation


struct MovieSearchApiResource: ApiResource {
    typealias ResponseType = PagedResponseDTO<MovieSearchResponseDTO>
    
    struct SearchQuery: Query {
        var query: String
        var include_adult: Bool
        var language: String = "ko-KR"
        var page: Int
    }
    
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String = "/3/search/movie"
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    
    init(method: HTTPMethod = .get, query: SearchQuery) {
        self.method = method
        self.query = query
    }
}
