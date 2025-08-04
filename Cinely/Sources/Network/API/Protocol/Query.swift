//
//  Query.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation

protocol Query {
    func makeQuery() -> [String: String]
}

extension Query {
    func makeQuery() -> [String : String] {
        let mirror = Mirror(reflecting: self)
        var result = [String: String]()
        for property in mirror.children {
            if let label = property.label {
                result[label] = "\(property.value)"
            }
        }
        return result
    }
}

struct EmptyQuery: Query {
    func makeQuery() -> [String : String] {
        [:]
    }
}
