//
//  MovieImageProvider.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation
import RxSwift
import HwanMacros

protocol MovieImageProvider {
    func fetchBackdrops(id: Int) -> Observable<MovieImageApiResource.ResponseType>
    func fetchCasts(id: Int) -> Observable<CreditsApiResource.ResponseType>
}

@Logging
final class DefaultMovieImageProvider: MovieImageProvider {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchBackdrops(id: Int) -> Observable<MovieImageApiResource.ResponseType> {
        networkManager.GET(
            resource: MovieImageApiResource(id: id),
            decodeType: MovieImageApiResource.ResponseType.self,
            decoder: nil
        )
    }
    
    func fetchCasts(id: Int) -> Observable<CreditsApiResource.ResponseType> {
        networkManager.GET(
            resource: CreditsApiResource(id: id),
            decodeType: CreditsApiResource.ResponseType.self,
            decoder: nil
        )
    }
}
