//
//  ErrorHandleProvider.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import RxSwift

import Alamofire

protocol ErrorHandleProvider {
    func convertToURLError(error: Error) -> ErrorMessage?
}

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

final class DefaultErrorHandleProviderProvider: ErrorHandleProvider {
    static let shared: ErrorHandleProvider = DefaultErrorHandleProviderProvider()
    func convertToURLError(error: Error) -> ErrorMessage? {
        if let AFError = error.asAFError {
            let title: String = "네트워크 에러"
            var message: String = "알 수 없는 오류가 발생했습니다. 잠시 후 다시 시도해주세요."
            
            switch AFError {
            case let .responseValidationFailed(reason: reason):
                switch  reason {
                default:
                    return nil
                }
            case let .sessionTaskFailed(error: error):
                if let urlError = error as? URLError {
                    switch urlError.code {
                    case .notConnectedToInternet:
                        message = "인터넷에 연결되어 있지 않습니다.\n Wi-Fi 또는 데이터 연결을 확인해주세요."
                        
                    case .timedOut:
                        message = "서버 응답이 지연되고 있습니다.\n잠시 후 다시 시도해주세요."
                        
                    case .cannotFindHost, .cannotConnectToHost:
                        message = "서버에 연결할 수 없습니다.\n 잠시 후 다시 시도해주세요."
                        
                    case .networkConnectionLost:
                        message = "네트워크 연결이 끊어졌습니다.\n 연결 상태를 확인하고 다시 시도해주세요."
                        
                    case .cancelled:
                        return nil
                        
                    default:
                        message = "일시적인 네트워크 오류가 발생했습니다.\n 잠시 후 다시 시도해주세요."
                    }
                    return ErrorMessage(title: title, message: message)
                }
            default:
                return ErrorMessage(title: title, message: message)
            }
        }
        return ErrorMessage(title: "시스템 에러",message: GlobalErrorType.unknownError(error).message)
    }
}

