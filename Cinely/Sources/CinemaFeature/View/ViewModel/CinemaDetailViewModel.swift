//
//  CinemaDetailViewModel.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation
import RxSwift
import RxCocoa

final class CinemaDetailViewModel {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let retryTrigger: Observable<Void>
        let isFavoriteTapped: Observable<Bool>
        let reloadComplete: Observable<Void>
    }
    
    struct Output {
        let movieDetailModels: Driver<[DetailSectionAndItem]>
        let lazyLoadingFavorite: Driver<Bool>
        let errorAlertTrigger: Driver<ErrorMessage>
        let isLoading: Driver<Bool>
    }
    
    struct Dependency {
        let appState: AppState
        let appStorage: PersistentStorage
        let movieImageProvider: MovieImageProvider
        let movieState: MovieState
    }
    
    struct MovieState {
        var movieModel: TodayMovieModel
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
    
    var movieState: MovieState
    private var disposeBag = DisposeBag()
    
    // MARK: Output
    private let movieDetailModels = BehaviorRelay<[DetailSectionAndItem]>(value: [])
    private let lazyLoadingFavorite = BehaviorRelay<Bool>(value: false)
    private let errorAlertTrigger = PublishRelay<ErrorMessage>()
    private let isLoading = BehaviorRelay<Bool>(value: true)
    
    func transform(input: Input) -> Output {        
        appState.favoriteMoviesState
            .subscribe(with: self, onNext: { vm, value in
                var model = vm.movieState.movieModel
                let isFavorite = value.contains(where: { $0.id == model.id })
                if isFavorite == model.favorite {
                    return
                }
                model.favorite = isFavorite
                vm.movieState.movieModel = model
                vm.lazyLoadingFavorite.accept(isFavorite)
            })
            .disposed(by: disposeBag)
        input.isFavoriteTapped
            .skip(1)
            .subscribe(with: self, onNext: { vm, isFavorite in
                let send = (vm.movieState.movieModel, isFavorite)
                vm.appState.favoriteListBinder.onNext(send)
            })
            .disposed(by: disposeBag)
        
        input.reloadComplete
            .map { _ in false }
            .bind(to: isLoading)
            .disposed(by: disposeBag)
        
        input.retryTrigger
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.isLoading.accept(true) })
            .flatMap { vm, _ in vm.fetchSection() }
            .bind(to: movieDetailModels)
            .disposed(by: disposeBag)
        
        input.viewDidLoad
            .withUnretained(self)
            .do(onNext: { vm, _ in vm.isLoading.accept(true) })
            .flatMap { vm, _ in vm.fetchSection() }
            .bind(to: movieDetailModels)
            .disposed(by: disposeBag)
        
        return Output(
            movieDetailModels: self.movieDetailModels.asDriver(),
            lazyLoadingFavorite: self.lazyLoadingFavorite.asDriver(),
            errorAlertTrigger: self.errorAlertTrigger.asDriver(onErrorJustReturn: ErrorMessage.default),
            isLoading: isLoading.asDriver()
        )
    }
    
    private func fetchSection() -> Observable<[DetailSectionAndItem]> {
        Observable.zip(_fetchPagingHeaderOb(), _fetchSynosisOb(), _fetchCastsOb())
            .withUnretained(self)
            .map { vm, item -> [DetailSectionAndItem] in
                return [DetailSectionAndItem(section: .pagingHeader, items: item.0)] +
                [DetailSectionAndItem(section: .synopsis, items: item.1)] +
                [DetailSectionAndItem(section: .casts, items: item.2)]
            }
    }
    
    private func _fetchSynosisOb() -> Observable<[MovieDetailItem]> {
        Observable.deferred { [weak self] in
            guard let self else { return Observable<[MovieDetailItem]>.empty() }
            return Observable<[MovieDetailItem]>.just(
                [.synopsis(self.movieState.movieModel.description)]
            )
        }
    }
    
    private func _fetchCastsOb() -> Observable<[MovieDetailItem]> {
        movieImageProvider
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
    }
        
    private func _fetchPagingHeaderOb() -> Observable<[MovieDetailItem]> {
        movieImageProvider
            .fetchBackdrops(id: movieState.movieModel.id)
            .compactMap(\.backdrops)
            .withUnretained(self)
            .withLatestFrom(appState.configurationState) { stream, configuration in
                let (vm, imageDTOList) = stream
                return if imageDTOList.isEmpty {
                    [MovieDetailItem.pagingHeader(MovieDetailModel(file_path: vm.movieState.movieModel.postImage))]
                } else {
                    imageDTOList.map {
                        MovieDetailItem.pagingHeader(MovieDetailModel(file_path: $0.backDropFilePath(configuration: configuration)))
                    }
                }
            }
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
