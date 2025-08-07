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

enum MovieDetailItem: Equatable, Hashable {
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
    
    static func == (lhs: MovieDetailItem, rhs: MovieDetailItem) -> Bool {
        switch (lhs, rhs) {
        case (.pagingHeader(let lhsModel), .pagingHeader(let rhsModel)):
            return lhsModel == rhsModel
            
        case (.synopsis(let lhsString), .synopsis(let rhsString)):
            return lhsString == rhsString
            
        case (.casts(let lhsCast), .casts(let rhsCast)):
            return lhsCast == rhsCast
            
        default:
            return false
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
