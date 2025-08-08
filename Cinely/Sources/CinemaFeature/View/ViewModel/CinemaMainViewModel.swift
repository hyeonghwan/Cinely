//
//  CinemaMainViewModel.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxCocoa
import RxSwift

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}

final class CinemaMainViewModel: ViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewWillAppear: Observable<Void>
        let favoriteButtonTapped: Observable<(TodayMovieModel, Bool)>
        let deleteRecentSearchModel: Observable<RecentSearchModel>
        let deleteAllRecentSearchModel: Observable<Void>
        let todayMovieRetryTrigger: Observable<Void>
        let reloadComplete: Observable<Void>
        let refreshingTrigger: Observable<Void>
    }
    
    struct Output {
        let section: Driver<[MainSectionAndItem]>
        let alertTrigger: Driver<ErrorMessage>
        let isLoading: Driver<Bool>
        let refreshingEnd: Driver<Void>
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let trendingMovieProvider: TrendingMovieProvider
    }
    
    struct MainSectionAndItem {
        let section: MainCollectionSection
        let items: [MainHashableItem]
        var updateType: UpdateType = .all
        
        enum UpdateType {
            case user
            case recentSearch
            case todayMovies
            case all
        }
        
        func mutate(favoriteSet: Set<Int>) -> MainSectionAndItem {
            if case .todayMovies = section {
                let hashableItem = items.map { item in
                    if case let .todayMovie(todayMovieModel) = item
                    {
                        let isFavorite = favoriteSet.contains(todayMovieModel.id)
                        var todayMovieModel = todayMovieModel
                        todayMovieModel.favorite = isFavorite ? true : false
                        return MainHashableItem.todayMovie(todayMovieModel)
                    } else {
                        return item
                    }
                }
                return MainSectionAndItem(section: .todayMovies, items: hashableItem)
            } else if case .header = section {
                let hashableItem = items.map { item in
                    if case let .user(user) = item {
                        var user = user
                        user.likeCount = favoriteSet.count
                        return MainHashableItem.user(user)
                    } else {
                        return item
                    }
                }
                return MainSectionAndItem(section: .header, items: hashableItem)
            } else {
                return self
            }
        }
        
        func mutate(recentSearches: [RecentSearchModel]) -> MainSectionAndItem {
            if case .recentSearchResult = section {
                let recentSearchItems: [MainHashableItem]
                =
                if recentSearches.isEmpty {
                    [.emptyRecentSearch]
                } else {
                    recentSearches.map { .recentSearch($0) }
                }
                let recentSearchSection = MainSectionAndItem(section: .recentSearchResult, items: recentSearchItems)
                return recentSearchSection
            } else {
                return self
            }
        }
        
        func mutate(isFavorite: Bool, tappedMovie: TodayMovieModel) -> MainSectionAndItem {
            if case .todayMovies = section {
                let hashableItem = items.map { item in
                    if case let .todayMovie(todayMovieModel) = item,
                       todayMovieModel.id == tappedMovie.id
                    {
                        var todayMovieModel = todayMovieModel
                        todayMovieModel.favorite = isFavorite
                        return MainHashableItem.todayMovie(todayMovieModel)
                    } else {
                        return item
                    }
                }
                return MainSectionAndItem(section: .todayMovies, items: hashableItem)
            } else {
                return self
            }
        }
        
        func mutate(user newUser: User) -> MainSectionAndItem {
            if case .header = section {
                let hashableItem = items.map { item in
                    if case let .user(user) = item {
                        var user = user
                        user.nickname = newUser.nickname
                        return MainHashableItem.user(user)
                    } else {
                        return item
                    }
                }
                return MainSectionAndItem(section: .header, items: hashableItem)
            } else {
                return self
            }
        }
    }
    
    init(dependency: Dependency) {
        self.appState = dependency.appState
        self.appStorage = dependency.appStorage
        self.trendingMovieProvider = dependency.trendingMovieProvider
    }
    
    // MARK: Dependency
    private let appState: AppState
    private let appStorage: PersistentStorage
    private let trendingMovieProvider: TrendingMovieProvider
    
    // MARK: Model
    private let sections = BehaviorRelay<[MainSectionAndItem]>(value: [])
    private let alertTrigger = PublishRelay<ErrorMessage>()
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let refreshingEnd = PublishRelay<Void>()
    
    private var viewDidLoaded = false
    private var lastFetchTime = Date.now
    private var disposeBag = DisposeBag()
    
    
    func transform(input: Input) -> Output {
        // MARK: Global State Binding
        appStateBinding()
        
        // MARK: Error Handle
        trendingMovieProvider
            .errorMessageSubscription
            .compactMap { errMessage in errMessage == nil ? ErrorMessage.default : errMessage }
            .bind(to: alertTrigger)
            .disposed(by: disposeBag)
        
        // MARK: Input Handle
        input.deleteRecentSearchModel
            .bind(to: appState.removeRecentSearchBinder)
            .disposed(by: disposeBag)
        
        input.deleteAllRecentSearchModel
            .bind(to: appState.removeAllRecentSearchBinder)
            .disposed(by: disposeBag)
    
        // MARK: Debounce background Update
        input.favoriteButtonTapped
            .groupBy { movie, isFavorite in movie.id }
            .flatMap { group -> Observable<(TodayMovieModel, Bool)> in
                group.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            }
            .map { $0 }
            .bind(to: appState.favoriteListBinder)
            .disposed(by: disposeBag)
        
        input.todayMovieRetryTrigger
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.isLoading.accept(true) })
            .flatMap { vm, _ in vm.fetchSectionDataStream() }
            .bind(to: sections)
            .disposed(by: disposeBag)
            
        input.refreshingTrigger
            .withUnretained(self)
            .flatMapLatest { vm, _ -> Observable<[MainSectionAndItem]> in
                if Date.now.timeIntervalSince(vm.lastFetchTime) < 5 {
                    vm.refreshingEnd.accept(())
                      return .empty()
                  } else {
                      return vm.fetchSectionDataStream()
                          .do(onNext: { _ in vm.lastFetchTime = Date.now },
                              onError: { _ in vm.refreshingEnd.accept(()) })
                  }
              }
            .bind(to: sections)
            .disposed(by: disposeBag)
            
        input.viewDidLoad
            .withUnretained(self)
            .do(onNext: { vm, value in
                vm.viewDidLoaded = true
                vm.isLoading.accept(true)
            })
            .flatMap { vm, _ in vm.fetchSectionDataStream() }
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        input.reloadComplete
            .map { _ in false }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        return Output(
            section: sections.asDriver(),
            alertTrigger: alertTrigger.asDriver(onErrorJustReturn: ErrorMessage.default),
            isLoading: isLoading.asDriver(),
            refreshingEnd: refreshingEnd.asDriver(onErrorJustReturn: ())
        )
    }
    
    private func appStateBinding() {
        appState.userState
             .distinctUntilChanged { $0.nickname == $1.nickname }
            .withLatestFrom(sections) { user, sectionItemList in
                sectionItemList.map { sectionItem in
                    sectionItem.mutate(user: user)
                }
            }
            .bind(to: sections)
            .disposed(by: disposeBag)
            
        appState.favoriteMoviesState.map { $0.map { model in model.id }}
            .filter { [weak self] _ in (self?.viewDidLoaded ?? false) }
            .withUnretained(self)
            .map { vm, favoritesIDs in
                let sectionItemList = vm.sections.value
                let favoriteSet = Set<Int>(favoritesIDs)
                return sectionItemList.map { sectionItem in
                    sectionItem.mutate(favoriteSet: favoriteSet)
                }
            }
            .bind(to: sections)
            .disposed(by: disposeBag)
        
        appState.searchResultState
            .withUnretained(self)
            .map { vm, recentSearchModels -> [MainSectionAndItem] in
                let sectionItemList = vm.sections.value
                return sectionItemList.map { item in
                    if item.section == .recentSearchResult {
                        return item.mutate(recentSearches: recentSearchModels)
                    } else {
                        return item
                    }
                }
            }
            .bind(to: sections)
            .disposed(by: disposeBag)
    }
    
    private func fetchSectionDataStream() -> Observable<[MainSectionAndItem]> {
        Observable.zip(
            _fetchTodayModel(),
            appState.userState.take(1),
            appState.searchResultState.take(1)
        )
            { movies, user, recentSearches  in
                let recentSearchItems: [MainHashableItem]
                =
                if recentSearches.isEmpty {
                    [.emptyRecentSearch]
                } else {
                    recentSearches.map { .recentSearch($0) }
                }
                
                let movieItems: [MainHashableItem]
                =
                if movies.isEmpty {
                    [.errorTodayMovie(ErrorMessage(title: "네트워크 에러", message: "네트워크 연결을 확인하고 \n 다시 시도해주세요"))]
                } else {
                    movies.map { .todayMovie($0) }
                }
                let headerSection = MainSectionAndItem(section: .header, items: [.user(user)])
                let recentSearchSection = MainSectionAndItem(section: .recentSearchResult, items: recentSearchItems)
                let movieSection = MainSectionAndItem(section: .todayMovies, items: movieItems)
                return [headerSection, recentSearchSection, movieSection]
            }
    }
    
    private func _fetchTodayModel() -> Observable<[TodayMovieModel]> {
        return Observable.zip(
            trendingMovieProvider.fetchTrendingMovies(),
            appState.genresState,
            appState.configurationState,
            appState.favoriteMoviesState.map { value in value.map(\.id)}
        )
        .compactMap { value in
            let (trendingDTO, genres, configuration, favoriteIDandFlags) = value
            let favoriteSets = Set<Int>(favoriteIDandFlags)
            return if let movieModels = trendingDTO.results {
                movieModels.map { responseDTO in
                    responseDTO.toVM(
                        isFavorite: favoriteSets.contains(responseDTO.id),
                        genres: genres,
                        configuration: configuration
                    )
                }
            } else {
                nil
            }
        }
    }
    
    private func fetchEmptyMovieSection() -> Observable<[MainSectionAndItem]> {
        Observable.zip(
            appState.userState.asObservable().take(1),
            appState.searchResultState.asObservable().take(1),
            _emptyFetching()
        )
        .map { user, recentSearches, movies -> [MainSectionAndItem] in
            let recentSearchItems: [MainHashableItem]
            =
            if recentSearches.isEmpty {
                [.emptyRecentSearch]
            } else {
                recentSearches.map { .recentSearch($0) }
            }
            
            let movieItems: [MainHashableItem]
            =
            if movies.isEmpty {
                [.errorTodayMovie(ErrorMessage(title: "네트워크 에러", message: "네트워크 연결을 확인하고 \n 다시 시도해주세요"))]
            } else {
                movies.map { .todayMovie($0) }
            }
            let headerSection = MainSectionAndItem(section: .header, items: [.user(user)])
            let recentSearchSection = MainSectionAndItem(section: .recentSearchResult, items: recentSearchItems)
            let movieSection = MainSectionAndItem(section: .todayMovies, items: movieItems)
            return [headerSection, recentSearchSection, movieSection]
        }
    }
    
    private func _emptyFetching() -> Observable<[TodayMovieModel]> {
        Observable.zip(
            appState.genresState.take(1),
            appState.configurationState.take(1),
            appState.favoriteMoviesState.take(1).map { movie in movie.map(\.id)},
            Observable<PagedResponseDTO<TrendingMovieResponseDTO>>.just(.init(page: 0, results: [], totalPages: 0, totalResults: 0))
        ).compactMap {
            let (genres, configuration, favoriteIDandFlags, trendingDTO) = $0
            let favoriteSets = Set<Int>(favoriteIDandFlags)
            return if let movieModels = trendingDTO.results {
                movieModels.map { responseDTO in
                    responseDTO.toVM(
                        isFavorite: favoriteSets.contains(responseDTO.id),
                        genres: genres,
                        configuration: configuration
                    )
                }
            } else {
                nil
            }
        }
    }
}
