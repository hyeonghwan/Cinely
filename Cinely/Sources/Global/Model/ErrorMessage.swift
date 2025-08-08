//
//  ErrorMessage.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import Foundation
import Alamofire

enum GlobalErrorType: Error {
    case AFError(AFError)
    case unknownError(Error)
    
    var message: String {
        switch self {
        case .AFError(let aFError):
            return "AFError: \(aFError.errorDescription ?? "none")"
        case .unknownError(let error):
            return "UnknownError: \(error.localizedDescription)"
        }
    }
}

struct ErrorMessage: Hashable, Equatable {
    let uuid = UUID()
    let title: String
    let message: String
    
    static func ==(_ lhs: Self, _ rhs: Self) -> Bool {
        lhs.uuid == rhs.uuid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
    
    var retry: () -> Void = { }
    
    static var `default`: ErrorMessage {
        ErrorMessage(title: "에러", message: "시스템 내부에서 발생했습니다. 관리자에게 문의 해주세요!")
    }
}
