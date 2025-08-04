//
//  ImageConfigurationDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct MovieImageConfigurationDTO: Decodable {
    let images: ImageConfigurationDTO?

    enum CodingKeys: String, CodingKey {
        case images
    }
}

struct ImageConfigurationDTO: Decodable {
    var baseURL: String?
    var secureBaseURL: String?
    var backdropSizes: [String]?
    var logoSizes: [String]?
    var posterSizes: [String]?
    var profileSizes: [String]?
    var stillSizes: [String]?

    enum CodingKeys: String, CodingKey {
        case baseURL = "base_url"
        case secureBaseURL = "secure_base_url"
        case backdropSizes = "backdrop_sizes"
        case logoSizes = "logo_sizes"
        case posterSizes = "poster_sizes"
        case profileSizes = "profile_sizes"
        case stillSizes = "still_sizes"
    }
}
