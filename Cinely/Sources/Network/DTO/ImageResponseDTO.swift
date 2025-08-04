//
//  ImageDTO.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

struct ImageResponseDTO: Decodable {
    let id: Int?
    let backdrops: [ImageDTO]?
    let logos: [ImageDTO]?
    let posters: [ImageDTO]?
}

struct ImageDTO: Decodable {
    let width: Int?
    let height: Int?
    let aspectRatio: Double?
    let language: String?
    let filePath: String?
    let voteAverage: Double?
    let voteCount: Int?

    enum CodingKeys: String, CodingKey {
        case width
        case height
        case aspectRatio = "aspect_ratio"
        case language = "iso_639_1"
        case filePath = "file_path"
        case voteAverage = "vote_average"
        case voteCount = "vote_count"
    }
}

extension ImageDTO {
    func backDropFilePath(configuration: ImageConfiguration) -> String {
        configuration.getBackDropSizeOrigin(filePath: self.filePath ?? "none")
    }
}
