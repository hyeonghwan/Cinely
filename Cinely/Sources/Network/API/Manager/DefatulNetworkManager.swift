//
//  DefatulNetworkManager.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import Alamofire
import RxSwift
import HwanMacros

@Logging
final class DefaultNetworkManager: NetworkManager {
    
    static let shared: NetworkManager = DefaultNetworkManager()
    
    private let defaultDecorder = JSONDecoder()
    
    private class API {
        static let session: Session = {
            let configuration = URLSessionConfiguration.af.default
            configuration.timeoutIntervalForRequest = 5
            let apiLogger = ApiEventLogger()
            return Session(configuration: configuration, eventMonitors: [apiLogger])
        }()
    }
    
    fileprivate init() {}
    
    func GET<Resource: ApiResource, DTO: Decodable>(resource: Resource,
                                                    decodeType: DTO.Type,
                                                    decoder: JSONDecoder? = nil,
                                                    completion: @escaping (Result<DTO, Error>) -> Void) -> DataRequest?
    {
        do {
            let urlRequest = try resource.urlRequest()
            return API.session.request(urlRequest, interceptor: .retryPolicy)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: DTO.self, decoder: decoder == nil ? defaultDecorder : decoder!) { result in
                    switch result.result {
                    case let .success(dto):
                        completion(.success(dto))
                        
                    case let .failure(error):
                        completion(.failure(error))
                    }
                }
        } catch {
            completion(.failure(error))
            return nil
        }
    }
    
    func GET<Resource: ApiResource, DTO: Decodable>(resource: Resource,
                                                    decodeType: DTO.Type,
                                                    decoder: JSONDecoder? = nil) -> Observable<DTO>
    {
        Observable<DTO>.create { [weak self] observer in
            guard let self else { return Disposables.create() }
            do {
                let urlRequest = try resource.urlRequest()
                let dataRequest = API.session.request(urlRequest, interceptor: .retryPolicy)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: DTO.self, decoder: decoder == nil ? defaultDecorder : decoder!) { response in
                        switch response.result {
                        case .success(let dto):
                            observer.onNext(dto)
                            observer.onCompleted()
                        case .failure(let error):
                            observer.onError(error)
                        }
                    }
                return Disposables.create {
                    dataRequest.cancel()
                }
            } catch {
                observer.onError(error)
                return Disposables.create()
            }
        }
    }
    
}
