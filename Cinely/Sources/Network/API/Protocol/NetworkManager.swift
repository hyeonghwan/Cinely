//
//  NetworkManager.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import Alamofire
import RxSwift

protocol NetworkManager {
    func GET<Resource: ApiResource, DTO: Decodable>(resource: Resource,
                                                    decodeType: DTO.Type,
                                                    decoder: JSONDecoder?,
                                                    completion: @escaping (Result<DTO, Error>) -> Void) -> DataRequest?
    
    func GET<Resource: ApiResource, DTO: Decodable>(resource: Resource,
                                                    decodeType: DTO.Type,
                                                    decoder: JSONDecoder?) -> Observable<DTO>
}

extension NetworkManager {
    func GET<Resource: ApiResource, DTO: Decodable>(resource: Resource,
                                                    decodeType: DTO.Type,
                                                    decoder: JSONDecoder? = nil,
                                                    completion: @escaping (Result<DTO, Error>) -> Void) -> DataRequest?
    {
        self.GET(resource: resource, decodeType: decodeType, decoder: decoder, completion: completion)
    }
}
