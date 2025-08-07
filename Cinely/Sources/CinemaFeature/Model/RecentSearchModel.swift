//
//  RecentSearchModel.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation


struct RecentSearchModel: Hashable, Codable, Equatable {
    let word: String
    let lastSearchDate: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
    }
    
    static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.word == rhs.word
    }
    
    static let dummy: [RecentSearchModel] = [
        RecentSearchModel(word: "인터스텔라", lastSearchDate: "2025.08.02"),
        RecentSearchModel(word: "SF 영화 추천", lastSearchDate: "2025.08.01"),
        RecentSearchModel(word: "마동석", lastSearchDate: "2025.07.31"),
        RecentSearchModel(word: "웡카", lastSearchDate: "2025.07.29"),
        RecentSearchModel(word: "넷플릭스 신작", lastSearchDate: "2025.07.28"),
        RecentSearchModel(word: "애니메이션", lastSearchDate: "2025.07.25"),
        RecentSearchModel(word: "파묘", lastSearchDate: "2025.07.20"),
        RecentSearchModel(word: "이정재", lastSearchDate: "2025.07.15")
    ]
}

