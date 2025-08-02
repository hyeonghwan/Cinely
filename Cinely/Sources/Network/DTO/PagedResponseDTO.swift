//
//  PagedResponseDTO.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct PagedResponseDTO<DTO: Decodable>: Decodable {
    let page: Int?
    let results: [DTO]?
    let totalPages: Int?
    let totalResults: Int?

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
