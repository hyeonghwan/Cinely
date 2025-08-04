//
//  TMDBConfigurationResource.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

struct MovieImageConfigurationApiResource: ApiResource {
    typealias ResponseType = MovieImageConfigurationDTO
    
    struct ConfigutaionQuery: Query {
    }
    
    var host: String { ApiConfiguration.MOVIE_DB_URL }
    var path: String = "/3/configuration"
    var method: HTTPMethod
    var headers: [String : String]? = [
        "Authorization" : "Bearer \(ApiConfiguration.API_TOKEN)",
        "accept": "application/json"
    ]
    var query: any Query
    
    init(method: HTTPMethod = .get, query: ConfigutaionQuery = ConfigutaionQuery()) {
        self.method = method
        self.query = query
    }
}
