//
//  TrendingMovieProvider.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxSwift
import RxRelay

protocol TrendingMovieProvider: Provider {
    func fetchTrendingMovies() -> Observable<TrendingApiResource.ResponseType>
}


final class DefaultTrendingMovieProvider: TrendingMovieProvider {
    
    private let networkManager: NetworkManager
    
    var errorMessageSubscription: Observable<ErrorMessage?> {
        self._errorMessageSubscription.asObservable()
    }
    private(set) var _errorMessageSubscription: PublishRelay<ErrorMessage?>
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        _errorMessageSubscription = PublishRelay<ErrorMessage?>()
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
            }.catch { [weak self] error in
                let errorMessage = DefaultErrorHandleProviderProvider.shared.convertToURLError(error: error)
                self?._errorMessageSubscription.accept(errorMessage)
                return Observable<PagedResponseDTO<TrendingMovieResponseDTO>>.just(.init(page: 0, results: [], totalPages: 0, totalResults: 0))
            }
    }
}
