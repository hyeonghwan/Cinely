//
//  CinemaMainViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import RxCocoa
import RxSwift


final class CinemaMainViewController: BaseViewController {
    
    static func create(with viewModel: any ViewModel, coordinator: CinemaMainCoordinator) -> CinemaMainViewController {
        let vc = CinemaMainViewController()
        vc.viewModel = (viewModel as! CinemaMainViewModel) // as! DefaultCinemaMainViewModel
        vc.coordinator = coordinator
        return vc
    }
    
    private var diffableDataSources: UICollectionViewDiffableDataSource<MainCollectionSection, MainHashableItem>!
    private lazy var collectionView = CinemaCollectionView(layout: dataSourceCompositionalLayout())
    fileprivate var viewModel: CinemaMainViewModel!
    private weak var coordinator: CinemaMainCoordinator?
    private var indicatorContainerView = IndicatorContainerView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func addAttributes() {
        setIndicator(indicator: indicatorContainerView)
        setDefaultBackground()
        setNavigationTint()
        setNavigationColor()
        setNavigationBackButton()
        navigationSetting()
        diffableDataSourceSetting()
        self.collectionView.dataSource = diffableDataSources
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Color.green
        collectionView.refreshControl = refreshControl
    }
    
    private func navigationSetting() {
        self.navigationItem.title = "Cinely"
        self.navigationItem.rightBarButtonItem
        = UIBarButtonItem(image: Icons.magnifyingglass?.withTintColor(Color.green.withAlphaComponent(0.6)),
                          style: .plain,
                          target: nil,
                          action: nil)
    }
    
    override func addChild() {
        self.view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private var disposeBag = DisposeBag()
    private let movieSelected = PublishSubject<IndexPath>()
    private let favoriteButtonTapped = PublishSubject<(TodayMovieModel, Bool)>()
    private let viewDidLoad = PublishSubject<Void>()
    private let viewWillAppear = PublishSubject<Void>()
    private let deleteRecentSearchModel = PublishSubject<RecentSearchModel>()
    private let deleteAllRecentSearchModel = PublishSubject<Void>()
    private let reloadComplete = PublishRelay<Void>()
    private let todayMovieRetryTrigger = PublishRelay<Void>()
    private let refreshEnd = PublishRelay<Void>()
    
    override func binding() {
        self.navigationItem.rightBarButtonItem?.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                vc.coordinator?.moveToSearch()
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .bind(to: movieSelected)
            .disposed(by: disposeBag)
        
        movieSelected
            .subscribe(with: self, onNext: { (vc: CinemaMainViewController, indexPath) in
                guard let item = vc.diffableDataSources.itemIdentifier(for: indexPath) else {
                    return
                }
                if case let .todayMovie(movieModel) = item {
                    vc.coordinator?.moveToDetail(movieModel)
                } else if case let .recentSearch(recentSearchWord) = item {
                    vc.coordinator?.moveToSearch(word: recentSearchWord.word)
                } else if case let .user(user) = item {
                    if let coordinator = vc.coordinator as? NicknamePresentCoordinator {
                        coordinator.presentNicknameSetting(userNickName: user.nickname)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input:
                .init(
                    viewDidLoad: Observable.just(()),
                    viewWillAppear: viewWillAppear.asObservable(),
                    favoriteButtonTapped: favoriteButtonTapped,
                    deleteRecentSearchModel: deleteRecentSearchModel.asObservable(),
                    deleteAllRecentSearchModel: deleteAllRecentSearchModel.asObservable(),
                    todayMovieRetryTrigger: todayMovieRetryTrigger.asObservable(),
                    reloadComplete: reloadComplete.asObservable(),
                    refreshingTrigger: collectionView.refreshControl!.rx.controlEvent(.valueChanged).asObservable()
                )
        )
        
        output.isLoading
            .drive(with: self, onNext: { vc, value in
                if value {
                    vc.indicatorContainerView.isHidden = false
                    vc.indicatorContainerView.indicator.startAnimating()
                } else {
                    vc.indicatorContainerView.isHidden = true
                    vc.indicatorContainerView.indicator.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
        
        output.alertTrigger
            .map { [weak self] errMessage in
                var errMessage = errMessage
                errMessage.retry = { self?.todayMovieRetryTrigger.accept(()) }
                return errMessage
            }
            .drive(errorRetryAlert)
            .disposed(by: disposeBag)
        
        output.section
            .filter { !$0.isEmpty }
            .drive(with: self, onNext: { vc, models in
                vc.apply(sectionAndModels: models)
            })
            .disposed(by: disposeBag)
        
        output.refreshingEnd
            .drive(with: self, onNext: { vc, _ in
                vc.refreshEnd.accept(())
            })
            .disposed(by: disposeBag)
        
        refreshEnd
            .subscribe(with: self, onNext: { vc, _ in
                if vc.collectionView.refreshControl!.isRefreshing {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        vc.collectionView.refreshControl!.endRefreshing()
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func apply(sectionAndModels: [CinemaMainViewModel.MainSectionAndItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<MainCollectionSection, MainHashableItem>()
        
        for sectionAndModel in sectionAndModels {
            let section = sectionAndModel.section
            let items = sectionAndModel.items
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
        }
        
        if indicatorContainerView.isHidden == false {
            self.reloadComplete.accept(())
        }
        
        if let first = sectionAndModels.first, first.section == .todayMovies {
            self.diffableDataSources.applySnapshotUsingReloadData(snapshot)
        } else {
            self.diffableDataSources.apply(snapshot) { [weak self] in
                self?.refreshEnd.accept(())
            }
        }
    }
}

// MARK: Compositional + DiffableDataSource Setting
extension CinemaMainViewController {
    private func dataSourceCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .vertical
        config.interSectionSpacing = 6
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] section, environment in
            guard let self, let dataSource = self.diffableDataSources else {
                return NSCollectionLayoutSection(group: .init(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0))))
            }
            let section = dataSource.snapshot().sectionIdentifiers[section]
            switch section {
            case .header:
                return CinemaCollectionView.headerSection()
                
            case .recentSearchResult:
                let itemsInSection = dataSource.snapshot().itemIdentifiers(inSection: .recentSearchResult)
                if let first = itemsInSection.first, first == .emptyRecentSearch {
                    return CinemaCollectionView.emptyResultSection()
                } else {
                    return CinemaCollectionView.recentSearchSection()
                }
            case .todayMovies:
                let itemsInSection = dataSource.snapshot().itemIdentifiers(inSection: .todayMovies)
                if let first = itemsInSection.first, case .errorTodayMovie = first {
                    return CinemaCollectionView.errorMovieSection()
                } else {
                    return CinemaCollectionView.todayMovieSection()
                }
            }
        }, configuration: config)
    }
    
    private func diffableDataSourceSetting() {
        diffableDataSources = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            switch item {
            case let .user(user):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileContainerCell.id, for: indexPath) as? ProfileContainerCell else { return UICollectionViewCell() }
                cell.profileHeaderView.set(with: user)
                return cell
                
            case .recentSearch(let searchModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchResultCell.id, for: indexPath) as? RecentSearchResultCell else { return UICollectionViewCell() }
                
                cell.setText(searchModel.word)
                
                if let self {
                    cell.deleteButton.rx.tap
                        .map { _ in searchModel }
                        .bind(to: deleteRecentSearchModel)
                        .disposed(by: cell.disposeBag)
                }
                
                return cell
                
            case .emptyRecentSearch:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchEmptyCell.id, for: indexPath) as? RecentSearchEmptyCell else { return UICollectionViewCell() }
                
                return cell
                
            case let .errorTodayMovie(errorMessage):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ErrorRetryCell.id, for: indexPath) as? ErrorRetryCell else {
                    return UICollectionViewCell()
                }
                
                cell.settingErrorMessage(title: errorMessage.title, errorContent: errorMessage.message)
                
                if cell.retryButton.isLoading {
                    cell.retryButton.isLoading = false
                }
                
                if let self {
                    cell.retryButton.rx.tap
                        .withUnretained(cell)
                        .do(onNext: { cell, _ in cell.retryButton.isLoading.toggle() })
                        .map { $0.1 }
                        .bind(to: self.todayMovieRetryTrigger)
                        .disposed(by: cell.disposeBag)
                }
                
                return cell
                
            case let .todayMovie(movieModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMovieItemCell.id, for: indexPath) as? TodayMovieItemCell else { return UICollectionViewCell() }
                cell.set(with: movieModel)
                if let self {
                    cell.heartButton.rx.tap
                        .withUnretained(cell)
                        .map { cell, _ in
                            (movieModel,!cell.heartButton.isSelected)
                        }
                        .do(onNext: { [weak cell] value in
                            let (_, isFavorite) = value
                            cell?.heartButton.isSelected = isFavorite
                        })
                        .bind(to: favoriteButtonTapped)
                        .disposed(by: cell.disposeBag)
                }
                return cell
            }
        }
        
        diffableDataSources.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id, for: indexPath) as! SectionHeaderView
                    header.setTitle(indexPath.section == 1 ? "최근검색어" : "오늘의 영화")
                    header.setButtonTitle("전체삭제")
                    
                    if indexPath.section == 1, let self {
                        header.deleteButton.rx.tap
                            .bind(to: self.deleteAllRecentSearchModel)
                            .disposed(by: disposeBag)
                    }
                    
                    header.setDeleteButtonHidden(indexPath.section != 1)
                    return header
                }
            }
            return UICollectionReusableView()
        }
    }
}
