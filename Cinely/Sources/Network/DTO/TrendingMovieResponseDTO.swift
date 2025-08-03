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

extension TrendingMovieResponseDTO {
    private func mapToIfEmptyFirst(first: String?, second: String?) -> String {
        (first ?? "").isEmpty ? (second ?? "") : (first ?? "")
    }
    
    func fallBack(other: TrendingMovieResponseDTO) -> TrendingMovieResponseDTO {
        let overview = mapToIfEmptyFirst(first: self.overview, second: other.overview)
        return TrendingMovieResponseDTO(
            id: id,
            adult: adult,
            backdropPath: backdropPath,
            title: self.title,
            originalTitle: self.originalTitle,
            overview: overview,
            posterPath: self.posterPath,
            mediaType: self.mediaType,
            originalLanguage: self.originalLanguage,
            genreIds: self.genreIds,
            popularity: self.popularity,
            releaseDate: self.releaseDate,
            video: self.video,
            voteAverage: self.voteAverage,
            voteCount: self.voteCount
        )
    }
    
    func toVM(genres: [Int: Genre], configuration: ImageConfiguration) -> TodayMovieModel {
        let overviewIfEmpty = "줄거리를 제공하지 않습니다"
        return TodayMovieModel(
            id: self.id,
            postImage: configuration.getPosterPathSizeW500(filePath: self.posterPath ?? "none"),
            title: self.title ?? "N/A",
            description: (self.overview ?? overviewIfEmpty).isEmpty ? overviewIfEmpty : "\(self.overview ?? overviewIfEmpty)",
            favorite: false,
            genres: self.genreIds?.compactMap { genres[$0] } ?? ["N/A"],
            voteAverage: self.voteAverage ?? 0,
            releaseDate: self.releaseDate ?? ""
        )
    }
}
