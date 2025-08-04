//
//  ApiEventLogger.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Alamofire
import Foundation
import HwanMacros
  
@Logging
final class ApiEventLogger: EventMonitor, @unchecked Sendable {
    
    let queue = DispatchQueue(label: "myNetworkLogger")
    
    func requestDidFinish(_ request: Request) {
        let url_info = "URL: " + (request.request?.url?.absoluteString ?? "")  + "\n"
        + "Method: " + (request.request?.httpMethod ?? "") + "\n"
        + "Headers: " + "\(request.request?.allHTTPHeaderFields ?? [:])" + "\n"
        let auth_info = "Authorization: " + (request.request?.headers["Authorization"] ?? "")
        let body_info = "Body: " + (request.request?.httpBody?.toPrettyPrintedString ?? "")
        logger.log(level: .debug, "🛜 NETWORK Reqeust LOG")
        logger.log(level: .debug, "\(request.description)")
        logger.log(level: .debug, "\(url_info)")
        logger.log(level: .debug, "\(auth_info)")
        logger.log(level: .debug, "\(body_info)")
    }
    
    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
         let responseLog = "URL: " + (request.request?.url?.absoluteString ?? "") + "\n"
          + "Result: " + "\(response.result)" + "\n"
         + "StatusCode: " + "\(response.response?.statusCode ?? 0)" + "\n"
          + "Data: \(response.data?.toPrettyPrintedString ?? "")"
         logger.log(level: .debug, "🛜 NETWORK Response LOG")
         logger.log(level: .info, "\(responseLog)")
    }
}

extension Data {
    var toPrettyPrintedString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString as String
    }
}

