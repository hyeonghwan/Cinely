//
//  TrendingApiResource.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation


struct TrendingApiResource: ApiResource {
    typealias ResponseType = PagedResponseDTO<TrendingMovieResponseDTO>
    
    struct TrendingQuery: Query {
        var language: String = "ko-KR"
    }
    
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String = "/3/trending/movie/day"
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    
    init(method: HTTPMethod = .get, query: TrendingQuery = TrendingQuery()) {
        self.method = method
        self.query = query
    }
}
