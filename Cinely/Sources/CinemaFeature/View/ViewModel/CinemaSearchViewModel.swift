//
//  CinemaSearchViewModel.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CinemaSearchViewModel {
    struct Input {
        let submit: Observable<String>
        let paging: Observable<Void>
        let pagingFinish: Observable<Void>
        let favoriteButtonTapped: Observable<(row: Int, flag: Bool)>
        let viewDidLoad: Observable<Void>
        let searchModeTrigger: Observable<SearchMode>
        let allDeleteActionTrigger: Observable<Void>
        let recentSearchWordDeleteTrigger: Observable<RecentSearchModel>
    }
    
    struct Output {
        var outputData: Driver<[SearchItem]>
        var isPagingLoading: Driver<Bool>
        var alertTrigger: Driver<ErrorMessage>
    }
    
    enum SearchItem {
        case emptySearchResult
        case emptySearchHistory
        case movie(TodayMovieModel)
        case refresh
        case last
        case suggestion(RecentSearchModel)
    }
    
    enum SearchMode {
        case suggestion
        case searchResult
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let movieSearchProvider: MovieSearchProvider
        let word: String
    }
    
    private let appState: AppState
    private let appStorage: PersistentStorage
    private let movieSearchProvider: MovieSearchProvider
    
    init(dependency: Dependency) {
        self.appState = dependency.appState
        self.appStorage = dependency.appStorage
        self.movieSearchProvider = dependency.movieSearchProvider
        self.word = dependency.word
    }
    
    private let searchMovieList = BehaviorRelay<[SearchItem]>(value: [.emptySearchResult])
    private let suggestionModels = BehaviorRelay<[RecentSearchModel]>(value: [])
    private(set) var currentMode = BehaviorRelay<SearchMode>(value: .searchResult)
    
    private let currentPageState = BehaviorRelay<PagingState>(value: PagingState(currentPage: 1, queryText: "", total: 1))
    private let isPagingLoading = BehaviorRelay<Bool>(value: false)
    private var viewDidLoaded = false
    private let alertTrigger = PublishRelay<ErrorMessage>()
    private var disposeBag = DisposeBag()
    var word: String
    
    var outputData: Driver<[SearchItem]> {
        return Observable.combineLatest(
            currentMode,
            suggestionModels,
            searchMovieList
        )
        .map { mode, suggestions, searchResults -> [SearchItem] in
            switch mode {
            case .suggestion:
                let suggestions = suggestions.map { SearchItem.suggestion($0) }
                return suggestions.isEmpty ? [.emptySearchHistory] : suggestions
            case .searchResult:
                return searchResults
            }
        }
        .asDriver(onErrorJustReturn: [])
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(with: self, onNext: { vm, value in vm.viewDidLoaded = true })
            .disposed(by: disposeBag)
        
        input.favoriteButtonTapped
            .withLatestFrom(searchMovieList) { list, movies -> (movie: TodayMovieModel, isFavorite: Bool)? in
                let (row, isFavorite) = list
                return if case let .movie(movie) = movies[row] {
                    (movie, isFavorite)
                } else {
                    nil
                }
            }
            .compactMap { $0 }
            .bind(to: appState.favoriteListBinder)
            .disposed(by: disposeBag)
        
        input.allDeleteActionTrigger
            .bind(to: appState.removeAllRecentSearchBinder)
            .disposed(by: disposeBag)
        
        input.recentSearchWordDeleteTrigger
            .bind(to: appState.removeRecentSearchBinder)
            .disposed(by: disposeBag)
        
        appState.favoriteMoviesState.map { $0.map { model in model.id }}
            .filter { [weak self] _ in (self?.viewDidLoaded ?? false) }
            .withUnretained(self)
            .map { vm, favoritesIDs in
                let searchItemList = vm.searchMovieList.value
                return searchItemList.map { searchItem in
                    if case let .movie(movie) = searchItem {
                        var movie = movie
                        movie.favorite = favoritesIDs.contains(movie.id) ? true : false
                        return  .movie(movie)
                    } else {
                        return searchItem
                    }
                }
            }
            .bind(to: searchMovieList)
            .disposed(by: disposeBag)
        
        appState.searchResultState
            .bind(to: suggestionModels)
            .disposed(by: disposeBag)
        
        input.searchModeTrigger
            .bind(to: self.currentMode)
            .disposed(by: disposeBag)
        
        input.favoriteButtonTapped
            .withLatestFrom(searchMovieList) { path, movies in
                let (row, flag) = path
                var movies = movies
                if case var .movie(changedMovie) = movies[row] {
                    changedMovie.favorite = flag
                    movies[row] = .movie(changedMovie)
                }
                return movies
            }
            .bind(to: searchMovieList)
            .disposed(by: disposeBag)
        
        input.pagingFinish
            .map { _ in false }
            .bind(to: isPagingLoading)
            .disposed(by: disposeBag)
        
        input.submit
            .map { RecentSearchModel(word: $0, lastSearchDate: Date.now.toISO8601String()) }
            .bind(to: appState.addRecentSearchBinder)
            .disposed(by: disposeBag)
        
        let latestConfig = Observable.combineLatest(
            appState.genresState,
            appState.configurationState
        )
        
        input.submit
            .startWith(self.word)
            .filter { !$0.isEmpty }
            .withUnretained(self)
            .flatMap { (vm, query) -> Observable<(MovieSearchApiResource.ResponseType, String, [Int])> in
                Observable.zip(
                    vm.movieSearchProvider.search(page: 1, query: query),
                    Observable<String>.just(query),
                    vm.appState.favoriteMoviesState.map { $0.map { model in model.id }}
                )
            }
            .withLatestFrom(latestConfig) { dto, state in (dto, state) }
            .subscribe(with: self, onNext: { vm, tuple in
                let ((paged, query, favoriteIDs), (genres, config)) = tuple
                vm.loadSearchResult(
                    pagedResponse: paged,
                    query: query,
                    genres: genres,
                    configuration: config,
                    favoriteIDs: Set<Int>(favoriteIDs)
                )
            })
            .disposed(by: disposeBag)
        
        let pagingConfig = Observable.combineLatest(
            appState.genresState,
            appState.configurationState,
            self.currentPageState,
            appState.favoriteMoviesState.map { $0.map { model in model.id } }
        )
        
        let pagingInput = input.paging
            .withLatestFrom(currentMode)
            .filter { $0 == .searchResult }  // searchResult 모드일 때만
            .map { _ in () }
        
        pagingInput
            .withLatestFrom(isPagingLoading)
            .filter { !$0 }
            .do(onNext: { [weak self] _ in self?.isPagingLoading.accept(true) })
            .withLatestFrom(pagingConfig)
            .filter { $0.2.isPossibleCall }
            .withUnretained(self)
            .flatMap
        { vm, currentState -> Observable<(PagedResponseDTO<MovieSearchResponseDTO>, [Int: Genre], ImageConfiguration, PagingState, Set<Int>)> in
            var (genres, configuration, pagingState, favoriteIDs) = currentState
            guard let nextPage = pagingState.mutateNext() else { return .empty() }
            
            let search = vm.movieSearchProvider.search(
                page: nextPage,
                query: pagingState.queryText
            ).catch { error in
                vm.isPagingLoading.accept(false)
                if let errorMessage = DefaultErrorHandleProviderProvider.shared.convertToURLError(error: error) {
                    vm.alertTrigger.accept(errorMessage)
                }
                return Observable.empty()
            }
            
            return Observable.zip(
                search,
                Observable.just(genres),
                Observable.just(configuration),
                Observable.just(pagingState),
                Observable.just(Set<Int>(favoriteIDs))
            )
        }
        .subscribe(
            with: self,
            onNext: { vm, response in
                vm.applyPagingResult(
                    pagedResponse: response.0,
                    genres: response.1,
                    configuration: response.2,
                    pagingState: response.3,
                    favoriteIDs: response.4
                )
            }
        )
        .disposed(by: disposeBag)
        
        return Output(
            outputData: outputData,
            isPagingLoading: isPagingLoading.asDriver(),
            alertTrigger: alertTrigger.asDriver(onErrorJustReturn: .default)
        )
    }
    
    private func loadSearchResult(pagedResponse: MovieSearchApiResource.ResponseType,
                                  query: String,
                                  genres: [Int: Genre],
                                  configuration: ImageConfiguration,
                                  favoriteIDs: Set<Int>)
    {
        let (page, totalPage) = (pagedResponse.page ?? 1, pagedResponse.totalPages ?? 1)
        let models: [SearchItem] = (pagedResponse.results ?? []).map { value in
            SearchItem.movie(value.toVM(favoriteIDs: favoriteIDs,
                                        genres: genres,
                                        configuration: configuration))
        }
        let newPageState = PagingState(currentPage: page, queryText: query, total: totalPage)
        self.currentPageState.accept(newPageState)
        
        if models.isEmpty {
            self.searchMovieList.accept([SearchItem.emptySearchResult])
        } else {
            if newPageState.isLast {
                self.searchMovieList.accept(models + [.last])
            } else {
                self.searchMovieList.accept(models + [.refresh])
            }
        }
        self.currentMode.accept(.searchResult)
    }
    
    private func applyPagingResult(pagedResponse: MovieSearchApiResource.ResponseType,
                                   genres: [Int: Genre],
                                   configuration: ImageConfiguration,
                                   pagingState: PagingState,
                                   favoriteIDs: Set<Int>) {
        
        let (page, totalPage) = (pagedResponse.page ?? 1, pagedResponse.totalPages ?? 1)
        let newPageState = PagingState(currentPage: page, queryText: pagingState.queryText, total: totalPage)
        
        var models = (pagedResponse.results ?? []).map { (dto: MovieSearchResponseDTO) in
            SearchItem.movie(dto.toVM(favoriteIDs: favoriteIDs, genres: genres, configuration: configuration))
        }
        models.append(newPageState.isLast ? SearchItem.last : SearchItem.refresh)
        
        var currentList = self.searchMovieList.value
        currentList.removeLast()
        currentList.append(contentsOf: models)
        
        self.searchMovieList.accept(currentList)
        self.currentPageState.accept(newPageState)
        self.currentMode.accept(.searchResult)
    }
}

extension CinemaSearchViewModel {
    struct PagingState {
        var currentPage: Int
        var queryText: String
        var total: Int
        
        var isPossibleCall: Bool {
            self.currentPage <= self.total
        }
        var isLast: Bool {
            self.currentPage == self.total
        }
        
        mutating func totalUpdate(_ total: Int) {
            self.total = total
        }
        
        mutating func mutateNext() -> Int? {
            if self.currentPage + 1 <= self.total {
                self.currentPage += 1
                return self.currentPage
            } else {
                return nil
            }
        }
    }
}
