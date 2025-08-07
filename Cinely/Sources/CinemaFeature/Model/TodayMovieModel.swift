//
//  TodayMovieModel.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import Foundation

struct TodayMovieModel: Hashable, Codable {
    var id: Int
    let postImage:   String
    let title:       String
    let description: String
    var favorite:      Bool
    var genres:     [String] = ["액션", "SF", "모험", "애니메이션"]
    var voteAverage: Double = 0.0
    var releaseDate: String = "2025. 04. 25"
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(favorite)
    }
    
    static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.favorite == rhs.favorite
    }
}

extension TodayMovieModel {
    func copy(favorite: Bool) -> TodayMovieModel {
        return TodayMovieModel(
            id: self.id,
            postImage: self.postImage,
            title: self.title,
            description: self.description,
            favorite: favorite,
            genres: self.genres,
            voteAverage: self.voteAverage,
            releaseDate: self.releaseDate
        )
    }
}
