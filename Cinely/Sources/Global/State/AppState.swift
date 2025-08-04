//
//  AppState.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import HwanKit
import HwanMacros
import RxSwift

typealias Genre = String

protocol AppState {
    var userState: Observable<User> { get }
    var genresState: Observable<[Int: Genre]> { get }
    var searchResultState: Observable<[RecentSearchModel]> { get }
    var configurationState: Observable<ImageConfiguration> { get }
    func update(user: User)
    
    /// 앱 시작시 실행
    /// 1. genres id Mapping API Call
    /// 2. Recent Search Text
    /// 3. TMDB Configuration API Call
    func appBootStrap()
}

@Logging
final class DefaultAppState: AppState {
    
    struct Dependency {
        let appProvider: AppProvider
        let appStorage: PersistentStorage
    }
    
    init(dependency: Dependency) {
        self.appProvider = dependency.appProvider
        self.appStorage = dependency.appStorage
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: Dependency
    private let appProvider: AppProvider
    private let appStorage: PersistentStorage
    

    // MARK: State
    private let _userState = BehaviorSubject<User>(value: .default)
    private let _genresState = BehaviorSubject<[Int: Genre]>(value: [:])
    private let _searchResultState = BehaviorSubject<[RecentSearchModel]>(value: [])
    private let _configurationState = BehaviorSubject<ImageConfiguration>(value: ImageConfigurationDTO.init().toConfig())

    // MARK: Output
    var userState: Observable<User> { _userState.asObservable() }
    var genresState: Observable<[Int: Genre]> { _genresState.asObservable() }
    var searchResultState: Observable<[RecentSearchModel]> { _searchResultState.asObservable() }
    var configurationState: Observable<ImageConfiguration> { _configurationState.asObservable() }
    
    // TODO: Need Storage Dependency
    func update(user: User) {
        _userState.onNext(user)
    }
    
    func update(searchModel: RecentSearchModel) {
        do {
            var currentSearches = try _searchResultState.value()
            currentSearches.removeAll { $0.word == searchModel.word }
            currentSearches.insert(searchModel, at: 0)
            _searchResultState.onNext(currentSearches)
        } catch {
            assert(false, "failed Get SearchResult from Subject")
        }
    }
    
    private func update(genres: [GenreDTO]) {
        // TODO: Storage 저장 여부 결정
        let cachingGenre = genres.reduce(into: [Int: Genre]()) { map, next in
            if map[next.id] == nil {
                map[next.id] = next.name
            }
        }
        for (key, value) in cachingGenre {
            logger.log(level: .info, "key: \(key), value: \(value)")
        }
        _genresState.onNext(cachingGenre)
    }
    
    func appBootStrap() {
        appProvider.fetchGenres()
            .map(\.genres)
            .subscribe(
                with: self,
                onNext: { app, genresDTO in
                    app.logger.log(level: .info, "genresDTO: \(String(describing: genresDTO))")
                    app.update(genres: genresDTO)
                }, onError: { app, error in
                    // TODO: Error 처리, network 실패 처리 -> (어떻게 할까.....)
                    app.logger.log(level: .info, "error: \(String(describing: error))")
                }
            )
            .disposed(by: disposeBag)
        
         appProvider.fetchImageConfiguration()
            .compactMap { $0.images?.toConfig() }
             .subscribe(
                 with: self,
                 onNext: { app, config in
                     app._configurationState.onNext(config)
                 }, onError: { app, error in
                     app.logger.log(level: .info, "error: \(String(describing: error))")
                 }
             )
             .disposed(by: disposeBag)
        
//        _searchResultState.onNext(
//            appStorage.loadStorage()
//        )
    }
}
