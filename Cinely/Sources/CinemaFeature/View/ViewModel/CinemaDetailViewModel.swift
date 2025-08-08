//
//  CinemaDetailViewModel.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation
import HwanMacros
import RxSwift
import RxCocoa

@Logging
final class CinemaDetailViewModel {
    
    struct Input {
    }
    
    struct Output {
        let movieDetailModels: Driver<[DetailSectionAndItem]>
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let movieImageProvider: MovieImageProvider
        let movieState: MovieState
    }
    
    struct MovieState {
        let movieModel: TodayMovieModel
    }
    
    struct DetailSectionAndItem {
        let section: MovieDetailSection
        let items: [MovieDetailItem]
    }
    
    init(dependency: Dependency) {
        self.appState = dependency.appState
        self.appStorage = dependency.appStorage
        self.movieImageProvider = dependency.movieImageProvider
        self.movieState = dependency.movieState
    }
    
    // MARK: Dependency
    private let appState: AppState
    private let appStorage: PersistentStorage
    private let movieImageProvider: MovieImageProvider
    private let movieState: MovieState
    private var disposeBag = DisposeBag()
    
    // MARK: Output
    private let movieDetailModels = BehaviorRelay<[DetailSectionAndItem]>(value: [])
    
    func transform(input: Input) -> Output {
        let fetchPagingHeaderOb = movieImageProvider
            .fetchBackdrops(id: movieState.movieModel.id)
            .compactMap(\.backdrops)
            .withUnretained(self)
            .withLatestFrom(appState.configurationState) { stream, configuration in
                let (vm, imageDTOList) = stream
                return if imageDTOList.isEmpty {
                    [
                        MovieDetailItem.pagingHeader(
                            MovieDetailModel(
                                file_path: vm.movieState.movieModel.postImage
                            )
                        )
                    ]
                } else {
                    imageDTOList.map {
                        MovieDetailItem.pagingHeader(
                            MovieDetailModel(
                                file_path: $0.backDropFilePath(configuration: configuration)
                            )
                        )
                    }
                }
            }
            .catchAndReturn([
                MovieDetailItem.pagingHeader(
                    MovieDetailModel(
                        id: UUID(),
                        file_path: "\(movieState.movieModel.postImage)"
                    )
                )
            ])
        
        // TODO: 빈값으로 처리해야 나머지 값들이라도 들어갈 수 있음
        
        let fetchSynosisOb = Observable.deferred { [weak self] in
            guard let self else { return Observable<[MovieDetailItem]>.empty() }
            return Observable<[MovieDetailItem]>.just(
                [.synopsis(self.movieState.movieModel.description)]
            )
        }
        
        let fetchCastOb = movieImageProvider
            .fetchCasts(id: movieState.movieModel.id)
            .compactMap(\.cast)
            .withLatestFrom(appState.configurationState) { castDTOList, configuration in
                castDTOList.map { dto in
                    MovieDetailItem.casts(
                        dto.toVM(configuration: configuration)
                    )
                }
            }
            .catchAndReturn([MovieDetailItem.casts(
                Cast(profileImageURL: "", actorName: "none", roleName: "none")
            )])
        
        Observable.zip(fetchPagingHeaderOb, fetchSynosisOb, fetchCastOb)
            .withUnretained(self)
            .map { vm, item -> [DetailSectionAndItem] in
                return [DetailSectionAndItem(section: .pagingHeader, items: item.0)] +
                [DetailSectionAndItem(section: .synopsis, items: item.1)] +
                [DetailSectionAndItem(section: .casts, items: item.2)]
            }
            .subscribe(with: self, onNext: { vm, sectionAndItems in
                vm.movieDetailModels.accept(sectionAndItems)
            })
            .disposed(by: disposeBag)
        
        return Output(
            movieDetailModels: self.movieDetailModels.asDriver()
        )
    }
    
    private func apply(sectionAndItem: DetailSectionAndItem) -> [DetailSectionAndItem] {
        var currentItems = self.movieDetailModels.value
        if let index = currentItems.firstIndex(where: { item in item.section == sectionAndItem.section }) {
            currentItems[index] = sectionAndItem
        } else {
            currentItems.insert(sectionAndItem, at: sectionAndItem.section.rawValue)
        }
        return currentItems
    }
}
