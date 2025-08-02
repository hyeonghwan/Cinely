//
//  TrendingMovieDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct TrendingMovieResponseDTO: Decodable {
    let id: Int
    let adult: Bool?
    let backdropPath: String?
    let title: String?
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
    let mediaType: String?
    let originalLanguage: String?
    let genreIds: [Int]?
    let popularity: Double?
    let releaseDate: String?
    let video: Bool?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case title
        case overview
        case popularity
        case video
        case backdropPath = "backdrop_path"
        case originalTitle = "original_title"
        case posterPath = "poster_path"
        case mediaType = "media_type"
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}
