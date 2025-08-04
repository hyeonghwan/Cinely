//
//  BackdropListModel.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation

enum MovieDetailSection: Int {
    case pagingHeader = 0
    case synopsis
    case casts
}

enum MovieDetailItem: Hashable {
    case pagingHeader(MovieDetailModel)
    case synopsis(String)
    case casts(Cast)
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .pagingHeader(let movieDetailModel):
            hasher.combine(movieDetailModel)
        case .synopsis(let string):
            hasher.combine(string)
        case .casts(let cast):
            hasher.combine(cast)
        }
    }
}

struct MovieDetailModel: Hashable {
    var id: UUID = UUID()
    var file_path: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(file_path)
    }
}
