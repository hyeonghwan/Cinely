//
//  CastResponseDTO.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

struct CastResponseDTO: Decodable {
    let id: Int?
    let cast: [CastDTO]?
}

struct CastDTO: Decodable {
    let id: Int?
    let adult: Bool?
    let gender: Int?
    let name: String?
    let originalName: String?
    let popularity: Double?
    let character: String?
    let knownForDepartment: String?
    let profilePath: String?
    let castID: Int?
    let creditID: String?
    let order: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case adult
        case gender
        case name
        case originalName = "original_name"
        case popularity
        case character
        case knownForDepartment = "known_for_department"
        case profilePath = "profile_path"
        case castID = "cast_id"
        case creditID = "credit_id"
        case order
    }
}

extension CastDTO {
    func toVM(configuration: ImageConfiguration) -> Cast {
        Cast(
            profileImageURL: configuration.getProfilePathSizeOriginal(filePath: self.profilePath ?? ""),
            actorName: self.name ?? "John do",
            roleName: self.character ?? "Park Hyeong Hwan"
        )
    }
}
