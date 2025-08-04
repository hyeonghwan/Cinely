//
//  MovieSearchApiResource.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

struct MovieImageApiResource: ApiResource {
    typealias ResponseType = ImageResponseDTO
    
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    
    init(method: HTTPMethod = .get, id: Int, query: EmptyQuery = EmptyQuery()) {
        self.method = method
        self.path = "/3/movie" + "/\(id)/" + "images"
        self.query = query
    }
}

