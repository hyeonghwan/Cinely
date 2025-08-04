//
//  TrendingMovieProvider.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxSwift
import HwanMacros

protocol TrendingMovieProvider {
    func fetchTrendingMovies() -> Observable<TrendingApiResource.ResponseType>
}

@Logging
final class DefaultTrendingMovieProvider: TrendingMovieProvider {
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchTrendingMovies() -> Observable<PagedResponseDTO<TrendingMovieResponseDTO>> {
        let korean = networkManager.GET(
            resource: TrendingApiResource(),
            decodeType: PagedResponseDTO<TrendingMovieResponseDTO>.self,
            decoder: nil
        )
        let en_us = networkManager.GET(
            resource: TrendingApiResource(query: .init(language: "en-US")),
            decodeType: PagedResponseDTO<TrendingMovieResponseDTO>.self,
            decoder: nil
        )
        return Observable.zip(korean, en_us)
            .map { value in
                var pagedDTO = value.0
                pagedDTO.results = zip(value.0.results ?? [], value.1.results ?? [])
                    .map { ko, en in ko.fallBack(other: en) }
                return pagedDTO
            }
    }
}
