//
//  MovieImageProvider.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation
import RxSwift
import RxRelay

protocol Provider {
    var errorMessageSubscription: Observable<ErrorMessage?> { get }
}

protocol MovieImageProvider: Provider {
    func fetchBackdrops(id: Int) -> Observable<MovieImageApiResource.ResponseType>
    func fetchCasts(id: Int) -> Observable<CreditsApiResource.ResponseType>
}


final class DefaultMovieImageProvider: MovieImageProvider {
    private let networkManager: NetworkManager
    
    var errorMessageSubscription: Observable<ErrorMessage?> {
        _errorMessageSubscription.asObservable()
    }
    
    private(set) var _errorMessageSubscription: PublishRelay<ErrorMessage?>
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
        self._errorMessageSubscription = PublishRelay<ErrorMessage?>()
    }
    
    func fetchBackdrops(id: Int) -> Observable<MovieImageApiResource.ResponseType> {
        networkManager.GET(
            resource: MovieImageApiResource(id: id),
            decodeType: MovieImageApiResource.ResponseType.self,
            decoder: nil
        ).catch { [weak self] error in
            let errorMessage = DefaultErrorHandleProviderProvider.shared.convertToURLError(error: error)
            self?._errorMessageSubscription.accept(errorMessage)
            return Observable<ImageResponseDTO>.just(.init(id: nil, backdrops: [], logos: [], posters: []))
        }
    }
    
    func fetchCasts(id: Int) -> Observable<CreditsApiResource.ResponseType> {
        networkManager.GET(
            resource: CreditsApiResource(id: id),
            decodeType: CreditsApiResource.ResponseType.self,
            decoder: nil
        ).catch { [weak self] error in
            let errorMessage = DefaultErrorHandleProviderProvider.shared.convertToURLError(error: error)
            self?._errorMessageSubscription.accept(errorMessage)
            return Observable<CastResponseDTO>.just(.init(id: nil, cast: []))
        }
    }
}
