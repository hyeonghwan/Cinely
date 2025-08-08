//
//  MovieSearchProvider.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import RxSwift
import RxRelay

protocol MovieSearchProvider: Provider {
    func search(page: Int, query: String) -> Observable<MovieSearchApiResource.ResponseType>
}


final class DefaultMovieSearchProvider: MovieSearchProvider {
    private let networkManager: NetworkManager
    var errorMessageSubscription: Observable<ErrorMessage?> {
        self._errorMessageSubscription.asObservable()
    }
    private(set) var _errorMessageSubscription: PublishRelay<ErrorMessage?>
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        _errorMessageSubscription = PublishRelay<ErrorMessage?>()
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
        ).catch { [weak self] error in
            let errorMessage = DefaultErrorHandleProviderProvider.shared.convertToURLError(error: error)
            self?._errorMessageSubscription.accept(errorMessage)
            return Observable<MovieSearchApiResource.ResponseType>.just(.init(page: 0, totalPages: 0, totalResults: 0))
        }
    }
}


