//
//  GenreResponseDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct GenreResponseDTO: Decodable {
    let genres: [GenreDTO]
}

struct GenreDTO: Decodable, Hashable {
    let id: Int
    let name: String
}
