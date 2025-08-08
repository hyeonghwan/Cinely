//
//  Date+.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import HwanKit

extension Date {
    func toISO8601String() -> String {
        self.toFormatted("yyyy-MM-dd'T'HH:mm:ssZ")
    }
    
    func toStringDot() -> String {
        self.toFormatted("yyyy .MM .dd")
    }
    
    func toStringDash() -> String {
        self.toFormatted("yyyy-MM-dd")
    }
}

extension String {
    func ISOStringToDotString() -> String {
        self.toFormattedString(current: "yyyy-MM-dd'T'HH:mm:ssZ", after: "yyyy.MM.dd")
    }
}
