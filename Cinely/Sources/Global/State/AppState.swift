//
//  AppState.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import HwanKit

import RxSwift

typealias Genre = String

protocol AppState {
    var userState: Observable<User> { get }
    var genresState: Observable<[Int: Genre]> { get }
    var searchResultState: Observable<[RecentSearchModel]> { get }
    var configurationState: Observable<ImageConfiguration> { get }
    var favoriteMoviesState: Observable<[TodayMovieModel]> { get }
    
    /// 앱 시작시 실행
    /// 1. genres id Mapping API Call
    /// 2. TMDB Configuration API Call
    func appBootStrap()
    
    var signUpBinder: Binder<User> { get }
    var signOutBinder: Binder<Void> { get }
    var favoriteListBinder: Binder<(movie: TodayMovieModel, isFavorite: Bool)> { get }
    var changeNickNameBinder: Binder<String> { get }
    var addRecentSearchBinder: Binder<RecentSearchModel> { get }
    var removeRecentSearchBinder: Binder<RecentSearchModel> { get }
    var removeAllRecentSearchBinder: Binder<Void> { get }
}


final class DefaultAppState: AppState {
    
    struct Dependency {
        let appProvider: AppProvider
        let appStorage: PersistentStorage
    }
    
    init(dependency: Dependency) {
        self.appProvider = dependency.appProvider
        self.appStorage = dependency.appStorage
        
        self._userState = BehaviorSubject<User>(
            value: User(
                nickname: Storage.userName,
                likeCount: Storage.userLikeCount,
                signUpDate: Storage.userSignUpDate.ISOStringToDotString()
            )
        )
        self._searchResultState = BehaviorSubject<[RecentSearchModel]>(
            value: Storage.recentSearchModels
        )
        self._favoriteMoviesState = BehaviorSubject<[TodayMovieModel]>(
            value: Storage.favoriteMovie
        )
        
        let genresDictionary: [Int: Genre] = [
            28: "액션", 12: "모험", 37: "서부",
            16: "애니메이션", 35: "코미디", 53: "스릴러",
            80: "범죄", 99: "다큐멘터리", 10752: "전쟁",
            18: "드라마", 10751: "가족", 878: "SF",
            14: "판타지", 36: "역사", 10770: "TV 영화",
            27: "공포", 10402: "음악", 9648: "미스터리",
            10749: "로맨스"
        ]
        
        self._genresState = BehaviorSubject<[Int: Genre]>(
            value: genresDictionary
        )
    }
    
    private var disposeBag = DisposeBag()
    
    // MARK: Dependency
    private let appProvider: AppProvider
    private let appStorage: PersistentStorage
    

    // MARK: State
    private let _userState: BehaviorSubject<User>
    private let _searchResultState: BehaviorSubject<[RecentSearchModel]>
    private let _favoriteMoviesState: BehaviorSubject<[TodayMovieModel]>
    
    private let _genresState: BehaviorSubject<[Int: Genre]>
    private let _configurationState = BehaviorSubject<ImageConfiguration>(value: ImageConfigurationDTO.init().toConfig())

    // MARK: Output
    var userState: Observable<User> { _userState.asObservable() }
    var searchResultState: Observable<[RecentSearchModel]> { _searchResultState.asObservable() }
    var favoriteMoviesState: Observable<[TodayMovieModel]> { _favoriteMoviesState.asObservable() }
    
    var genresState: Observable<[Int: Genre]> { _genresState.asObservable() }
    var configurationState: Observable<ImageConfiguration> { _configurationState.asObservable() }
    
    func appBootStrap() {
        appProvider.fetchGenres()
            .map(\.genres)
            .subscribe(
                with: self,
                onNext: { app, genresDTO in
                    app.update(genres: genresDTO)
                }, onError: { app, error in
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
                 }
             )
             .disposed(by: disposeBag)
    }
    
    private func update(genres: [GenreDTO]) {
        let cachingGenre = genres.reduce(into: [Int: Genre]()) { map, next in
            if map[next.id] == nil {
                map[next.id] = next.name
            }
        }
        _genresState.onNext(cachingGenre)
    }
}


extension DefaultAppState: ReactiveCompatible {
    var signUpBinder: Binder<User> {
        Binder<User>(self) { appState, user in
            Storage.userName = user.nickname
            Storage.userSignUpDate = user.signUpDate
            Storage.userLikeCount = 0
            var user = user
            user.signUpDate = user.signUpDate.ISOStringToDotString()
            appState._userState.onNext(user)
        }
    }
    
    var signOutBinder: Binder<Void> {
        Binder<Void>(self) { appState, user in
            appState._userState.onNext(.default)
            appState._searchResultState.onNext([])
            appState._favoriteMoviesState.onNext([])
            Storage.userName = ""
            Storage.userSignUpDate = ""
            Storage.userLikeCount = 0
            Storage.favoriteMovie = []
            Storage.recentSearchModels = []
        }
    }

    var favoriteListBinder: Binder<(movie: TodayMovieModel, isFavorite: Bool)> {
        Binder<(movie: TodayMovieModel, isFavorite: Bool)>(self) { appState, list in
            var current = Set<TodayMovieModel>(Storage.favoriteMovie)
            let (movie, isFavorite) = list
            
            if movie.favorite == isFavorite {
                return
            }
            
            let trueModel = movie.copy(favorite: true)
            if isFavorite {
                current.insert(trueModel)
            } else {
                current.remove(trueModel)
            }
            if let user = try? appState._userState.value() {
                let updatedUser = User(nickname: user.nickname, likeCount: current.count, signUpDate: user.signUpDate)
                appState._userState.onNext(updatedUser)
                Storage.userLikeCount = current.count
            }
            let nextState = Array(current)
            appState._favoriteMoviesState.onNext(nextState)
            Storage.favoriteMovie = nextState
        }
    }
    
    var changeNickNameBinder: Binder<String> {
        Binder<String>(self) { appState, chageName in
            if let user = try? appState._userState.value() {
                appState._userState.onNext(
                    User(
                        nickname: chageName,
                        likeCount: user.likeCount,
                        signUpDate: user.signUpDate
                    )
                )
                Storage.userName = chageName
            }
        }
    }
    
    var addRecentSearchBinder: Binder<RecentSearchModel> {
        Binder<RecentSearchModel>(self) { appState, searchModel in
            if var currentSearchState = try? appState._searchResultState.value() {
                currentSearchState.removeAll(where: { $0.word == searchModel.word })
                currentSearchState.insert(searchModel, at: 0)
                Storage.recentSearchModels = currentSearchState
                appState._searchResultState.onNext(currentSearchState)
            }
        }
    }
    
    var removeRecentSearchBinder: Binder<RecentSearchModel> {
        Binder<RecentSearchModel>(self) { appState, searchModel in
            if var currentSearchState = try? appState._searchResultState.value() {
                currentSearchState.removeAll(where: { $0.word == searchModel.word })
                Storage.recentSearchModels = currentSearchState
                appState._searchResultState.onNext(currentSearchState)
            }
        }
    }
    
    var removeAllRecentSearchBinder: Binder<Void> {
        Binder<Void>(self) { appState, _ in
            Storage.recentSearchModels = []
            appState._searchResultState.onNext([])
        }
    }
}
