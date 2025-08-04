//
//  CinemaSearchViewModel.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import Foundation
import RxSwift
import RxCocoa
import HwanMacros

@Logging
final class CinemaSearchViewModel {
    
    struct Input {
        let submit: Observable<String>
        let paging: Observable<Void>
        let pagingFinish: Observable<Void>
        let favoriteButtonTapped: Observable<(row: Int, flag: Bool)>
    }
    
    struct Output {
        var results: Driver<[SearchItem]>
        var isPagingLoading: Driver<Bool>
    }
    
    enum SearchItem {
        case empty
        case movie(TodayMovieModel)
        case refresh
        case last
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let movieSearchProvider: MovieSearchProvider
    }
    
    private let appState: AppState
    private let appStorage: PersistentStorage
    private let movieSearchProvider: MovieSearchProvider
    
    init(dependency: Dependency) {
        appState = dependency.appState
        appStorage = dependency.appStorage
        movieSearchProvider = dependency.movieSearchProvider
    }
    
    private let searchMovieList = BehaviorRelay<[SearchItem]>(value: [.empty])
    private let currentPageState = BehaviorRelay<PagingState>(value: PagingState(currentPage: 1, queryText: "", total: 1))
    private let isPagingLoading = BehaviorRelay<Bool>(value: false)
    private var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        input.favoriteButtonTapped
            .buffer(timeSpan: .seconds(2), count: 5, scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { vm, value in
                for i in 0..<value.count {
                    vm.logger.log(level: .fault, "i: \(String(describing: value[i]))")
                }
            }, onError: { vm, error  in
                vm.logger.log(level: .fault, "error: \(String(describing: error))")
            })
            .disposed(by: disposeBag)
        
        input.favoriteButtonTapped
            .withLatestFrom(searchMovieList) { path, movies in
                let (row, flag) = path
                var movies = movies
                if case var .movie(changedMovie) = movies[row] {
                    changedMovie.favorite = flag
                    movies[row] = .movie(changedMovie)
                    self.logger.log(
                        level: .fault,
                        "favoriteButtonTapped Model- Storage.favoriteMovie \(String(describing: Storage.favoriteMovie.map(\.id)))"
                    )
                }
                return movies
            }
            .bind(to: searchMovieList)
            .disposed(by: disposeBag)
        
        input.pagingFinish.subscribe(
            with: self, onNext: { vm, _ in
                vm.isPagingLoading.accept(false)
            }
        )
        .disposed(by: disposeBag)
        
        let latestConfig = Observable.combineLatest(
            appState.genresState,
            appState.configurationState
        )
        
        input.submit
            .withUnretained(self)
            .flatMap { (vm, query) -> Observable<(MovieSearchApiResource.ResponseType, String)> in
                Observable.zip(vm.movieSearchProvider.search(page: 1, query: query), Observable<String>.just(query))
            }
            .withLatestFrom(latestConfig) { dto, state in (dto, state) }
            .subscribe(with: self, onNext: { vm, tuple in
                vm.loadSearchResult(tuple: tuple)
            })
            .disposed(by: disposeBag)
        
        let pagingConfig = Observable.combineLatest(
            appState.genresState,
            appState.configurationState,
            self.currentPageState
        )
        
        input.paging
            .withLatestFrom(isPagingLoading)
            .filter { !$0 }
            .do(onNext: { [weak self] _ in self?.isPagingLoading.accept(true) })
            .withLatestFrom(pagingConfig)
            .filter { $0.2.isPossibleCall }
            .withUnretained(self)
            .flatMap { vm, currentState -> Observable<(PagedResponseDTO<MovieSearchResponseDTO>, [Int: Genre], ImageConfiguration, PagingState)> in
                var (genres, configuration, pagingState) = currentState
                guard let nextPage = pagingState.mutateNext() else { return .empty() }
                
                let search = vm.movieSearchProvider.search(
                    page: nextPage,
                    query: pagingState.queryText
                )
                
                return Observable.zip(
                    search,
                    Observable.just(genres),
                    Observable.just(configuration),
                    Observable.just(pagingState)
                )
            }
            .subscribe(with: self, onNext: { vm, response in
                vm.applyPagingResult(response: response)
            })
            .disposed(by: disposeBag)
        
        return Output(
            results: searchMovieList.asDriver(),
            isPagingLoading: isPagingLoading.asDriver()
        )
    }
    
    private func loadSearchResult(tuple: ((MovieSearchApiResource.ResponseType, String), ([Int: Genre], ImageConfiguration))) {
        let ((pagedResponse, query), (genres, configuration)) = tuple
        let (page, totalPage) = (pagedResponse.page ?? 1, pagedResponse.totalPages ?? 1)
        let models: [SearchItem] = (pagedResponse.results ?? []).map { value in
            SearchItem.movie(value.toVM(genres: genres, configuration: configuration))
        }
        let newPageState = PagingState(currentPage: page, queryText: query, total: totalPage)
        self.currentPageState.accept(newPageState)
        
        if models.isEmpty {
            self.searchMovieList.accept([SearchItem.empty])
        } else {
            if newPageState.isLast {
                self.searchMovieList.accept(models + [.last])
            } else {
                self.searchMovieList.accept(models + [.refresh])
            }
        }
    }
    
    private func applyPagingResult(response: (MovieSearchApiResource.ResponseType, [Int: Genre], ImageConfiguration, PagingState)) {
        let (pagedResponse, genres, configuration, pagingState) = response
        
        let (page, totalPage) = (pagedResponse.page ?? 1, pagedResponse.totalPages ?? 1)
        let newPageState = PagingState(currentPage: page, queryText: pagingState.queryText, total: totalPage)
        
        var models = (pagedResponse.results ?? []).map { (dto: MovieSearchResponseDTO) in
            SearchItem.movie(dto.toVM(genres: genres, configuration: configuration))
        }
        models.append(newPageState.isLast ? .last : .refresh)
        
        var currentList = self.searchMovieList.value
        currentList.removeLast()
        currentList.append(contentsOf: models)
        
        self.searchMovieList.accept(currentList)
        self.currentPageState.accept(newPageState)
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
