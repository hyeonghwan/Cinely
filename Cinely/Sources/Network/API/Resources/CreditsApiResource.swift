//
//  CreditsApiResource.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

struct CreditsApiResource: ApiResource {
    typealias ResponseType = CastResponseDTO
    struct CastQuery: Query {
        var language: String = "ko-KR"
    }
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    init(method: HTTPMethod = .get, id: Int, query: CastQuery = CastQuery()) {
        self.method = method
        self.path = "/3/movie/\(id)/credits"
        self.query = query
    }
}
