//
//  GlobalProvider.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxSwift

protocol AppProvider {
    func fetchGenres() -> Observable<GenreResponseDTO>
    func fetchImageConfiguration() -> Observable<MovieImageConfigurationDTO>
}

final class DefaultAppProvider: AppProvider {
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    func fetchGenres() -> Observable<GenreResponseDTO> {
        networkManager.GET(
            resource: GenreApiResource(),
            decodeType: GenreResponseDTO.self,
            decoder: nil
        )
    }
    
    func fetchImageConfiguration() -> Observable<MovieImageConfigurationDTO> {
        networkManager.GET(
            resource: MovieImageConfigurationApiResource(),
            decodeType: MovieImageConfigurationDTO.self,
            decoder: nil
        )
    }
}
