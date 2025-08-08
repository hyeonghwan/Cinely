//
//  CinemaMainViewModel.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxCocoa
import RxSwift


final class CinemaMainViewModel {
    struct Input {
        
    }
    
    struct Output {
        let section: Driver<[MainSectionAndItem]>
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let trendingMovieProvider: TrendingMovieProvider
    }
    
    struct MainSectionAndItem {
        let section: MainCollectionSection
        let items: [MainHashableItem]
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
    private var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let trendingObservable
        =
        Observable.combineLatest(
            appState.genresState,
            appState.configurationState,
            trendingMovieProvider.fetchTrendingMovies()
        ).compactMap {
            let (genres, configuration, trendingDTO) = $0
            return if let movieModels = trendingDTO.results {
                movieModels.map {
                    $0.toVM(
                        genres: genres,
                        configuration: configuration
                    )
                }
            } else {
                nil
            }
        }
        
        Observable.combineLatest(
            appState.userState.asObservable(),
            appState.searchResultState.asObservable(),
            trendingObservable
        )
        .map { user, recentSearches, movies -> [MainSectionAndItem] in
            let recentSearchItems: [MainHashableItem]
            =
            if recentSearches.isEmpty {
                [.emptyRecentSearch]
            } else {
                recentSearches.map { .recentSearch($0) }
            }
            
            let headerSection = MainSectionAndItem(section: .header, items: [.user(user)])
            let recentSearchSection = MainSectionAndItem(section: .recentSearchResult, items: recentSearchItems)
            let movieItems: [MainHashableItem] = movies.map { .todayMovie($0) }
            let movieSection = MainSectionAndItem(section: .todayMovies, items: movieItems)
            return [headerSection, recentSearchSection, movieSection]
        }
        .bind(to: sections)
        .disposed(by: disposeBag)
        
        return Output(
            section: sections.asDriver()
        )
    }
}
