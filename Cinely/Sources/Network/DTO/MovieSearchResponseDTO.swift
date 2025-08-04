//
//  MovieSearchResponseDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct MovieSearchResponseDTO: Decodable {
    let id: Int
    let adult: Bool?
    let backdropPath: String?
    let title: String?
    let originalTitle: String?
    let overview: String?
    let posterPath: String?
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
        case originalLanguage = "original_language"
        case genreIds = "genre_ids"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension MovieSearchResponseDTO {
    func toVM(genres: [Int: Genre], configuration: ImageConfiguration) -> TodayMovieModel {
        TodayMovieModel(
            id: self.id,
            postImage: configuration.getPosterPathSizeW342(filePath: self.posterPath ?? ""),
            title: self.title ?? "N/A",
            description: self.overview ?? "N/A",
            favorite: false,
            genres: self.genreIds?.compactMap { genres[$0] } ?? ["N/A"],
            voteAverage: self.voteAverage ?? 0,
            releaseDate: self.releaseDate ?? "None"
        )
    }
}
