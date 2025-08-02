//
//  TodayMovieModel.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import Foundation

struct TodayMovieModel {
    let postImage:   String
    let title:       String
    let description: String
    var favorite:      Bool
    var genres:     [String] = ["액션", "SF", "모험", "애니메이션"]
    var releaseDate: String = "2025. 04. 25"
    
    static var dummyList: [Self] {
        [
            TodayMovieModel(
                postImage: "heart",
                title: "기생충",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            ),
            TodayMovieModel(
                postImage: "heart",
                title: "하얼빈",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            ),
            TodayMovieModel(
                postImage: "heart",
                title: "어벤져스",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            ),
            TodayMovieModel(
                postImage: "heart",
                title: "하위",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            ),
            TodayMovieModel(
                postImage: "heart",
                title: "워킹데드",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            ),
            TodayMovieModel(
                postImage: "heart",
                title: "왕좌의 게임",
                description: "전원 백수로 살 길 막막하지만 사이는 좋은 기택 가족, 장남 기우에게 명문대생 친구가 이러쿵 저러쿵 요러쿵 있었던 것이었다.....",
                favorite: false
            )
        ]
    }
}

struct SearchItem {
    let searchText: String
    var date: Date = Date.now
}
