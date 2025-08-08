//
//  User.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

struct User: Hashable {
    var nickname:   String
    var likeCount: Int
    var signUpDate: String
    
    static var `default`: Self {
        User(nickname: "hyeonghwan",likeCount: 12, signUpDate: Date.now.toFormatted("yyyy.MM.dd"))
    }
}
