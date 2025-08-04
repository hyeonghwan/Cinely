//
//  MovieSearchProvider.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import RxSwift
import HwanMacros

protocol MovieSearchProvider {
    func search(page: Int, query: String) -> Observable<MovieSearchApiResource.ResponseType>
}

@Logging
final class DefaultMovieSearchProvider: MovieSearchProvider {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func search(page: Int, query: String) -> Observable<MovieSearchApiResource.ResponseType> {
        networkManager.GET(
            resource: MovieSearchApiResource(
                query: .init(
                    query: query,
                    include_adult: false,
                    page: page
                )
            ),
            decodeType: MovieSearchApiResource.ResponseType.self,
            decoder: nil
        )
    }
}


