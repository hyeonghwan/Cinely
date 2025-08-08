//
//  CinemaMainViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import HwanMacros
import RxCocoa
import RxSwift

@Logging
final class CinemaMainViewController: BaseViewController {
    
    static func create(with viewModel: CinemaMainViewModel) -> CinemaMainViewController {
        let vc = CinemaMainViewController()
        vc.viewModel = viewModel
        return vc
    }
    
    private var diffableDataSources: UICollectionViewDiffableDataSource<MainCollectionSection, MainHashableItem>!
    private lazy var collectionView = CinemaCollectionView(layout: dataSourceCompositionalLayout())
    fileprivate var viewModel: CinemaMainViewModel!
    private var disposeBag = DisposeBag()
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        navigationSetting()
        diffableDataSourceSetting()
        self.collectionView.dataSource = diffableDataSources
    }
    
    private func navigationSetting() {
        self.navigationItem.title = "Cinely"
        self.navigationItem.rightBarButtonItem
        = UIBarButtonItem(image: Icons.magnifyingglass?.withTintColor(Color.green.withAlphaComponent(0.6)),
                          style: .plain,
                          target: self,
                          action: #selector(moveToSearch(_:)))
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
    
    private let movieSelected = PublishSubject<IndexPath>()
    
    override func binding() {
        collectionView.rx.itemSelected
            .bind(to: movieSelected)
            .disposed(by: disposeBag)
        
        movieSelected
            .subscribe(with: self, onNext: { (vc: CinemaMainViewController, indexPath) in
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    return
                }
                guard let item = vc.diffableDataSources.itemIdentifier(for: indexPath) else {
                    return
                }
                if case let .todayMovie(movieModel) = item {
                    let detailVC = CinemaDetailViewController.create(
                        with: .init(
                            vmDependency: CinemaDetailViewModel.Dependency.init(
                                appState: appDelegate.appState,
                                appStorage: appDelegate.storage,
                                movieImageProvider: DefaultMovieImageProvider(networkManager: appDelegate.networkManager),
                                movieState: CinemaDetailViewModel
                                    .MovieState(
                                        movieModel: movieModel
                                    )
                            ),
                            movieModel: movieModel)
                    )
                    vc.navigationController?.pushViewController(detailVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        let output = viewModel.transform(input: .init())
        output.section
            .drive(with: self, onNext: { vc, models in
                vc.apply(sectionAndModels: models)
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
        self.diffableDataSources.apply(snapshot)
    }
    
    @objc
    private func moveToSearch(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let searchVC = CinemaMovieSearchVIewController.create(
            with: CinemaSearchViewModel(
                dependency: .init(
                    appState: appDelegate.appState,
                    appStorage: appDelegate.storage,
                    movieSearchProvider: appDelegate.movieSearchProvider
                )
            )
        )
        
        self.navigationController?.pushViewController(searchVC, animated: true)
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
                return CinemaCollectionView.todayMovieSection()
            }
        }, configuration: config)
    }
    
    private func diffableDataSourceSetting() {
        diffableDataSources = UICollectionViewDiffableDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case let .user(user):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileContainerCell.id, for: indexPath) as? ProfileContainerCell else { return UICollectionViewCell() }
                cell.set(with: user)
                return cell
                
            case .recentSearch(let searchModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchResultCell.id, for: indexPath) as? RecentSearchResultCell else { return UICollectionViewCell() }
                cell.setText(searchModel.word)
                return cell
                
            case .emptyRecentSearch:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchEmptyCell.id, for: indexPath) as? RecentSearchEmptyCell else { return UICollectionViewCell() }
                return cell
                
            case let .todayMovie(movieModel):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMovieItemCell.id, for: indexPath) as? TodayMovieItemCell else { return UICollectionViewCell() }
                cell.set(with: movieModel)
                return cell
            }
        }
        
        diffableDataSources.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id, for: indexPath) as! SectionHeaderView
                    header.setTitle(indexPath.section == 1 ? "최근검색어" : "오늘의 영화")
                    header.setButtonTitle("전체삭제")
                    header.setDeleteButtonHidden(indexPath.section != 1)
                    return header
                }
            }
            return UICollectionReusableView()
        }
    }
}
