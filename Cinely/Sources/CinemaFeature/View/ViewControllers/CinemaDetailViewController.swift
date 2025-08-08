//
//  CinemaDetailViewController.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design
import RxCocoa
import RxSwift
import HwanMacros
import Kingfisher

@Logging
final class CinemaDetailViewController: BaseViewController {
    
    struct Dependency {
        let vmDependency: CinemaDetailViewModel.Dependency
        let movieModel: TodayMovieModel
    }
    
    static func create(with dependency: Dependency) -> CinemaDetailViewController {
        let vc = CinemaDetailViewController()
        vc.detailViewModel = CinemaDetailViewModel(dependency: dependency.vmDependency)
        vc.movieModel = dependency.movieModel
        return vc
    }
    
    private var diffableDataSources: UICollectionViewDiffableDataSource<MovieDetailSection, MovieDetailItem>!
    fileprivate var detailViewModel: CinemaDetailViewModel!
    private lazy var collectionView    = CinemaDetailCollectionView(layout: compositionalLayout())
    private let pageControl = UIPageControl()
    
    private var movieModel: TodayMovieModel!
    private var isSynopsisSectionExpanded: Bool = false
    private var isSynopsisPossibleExpand: Bool = false
    private var disposeBag = DisposeBag()
    
    deinit {
        KingfisherManager.shared.cache.clearMemoryCache()
        logger.log(level: .fault, "CinemaDetailVC deinit Kingfisher Memory Clean")
    }
    
    // MARK: EVENT
    private let moreButtonTapped = PublishSubject<Void>()
    private let synopsisHeaderState = BehaviorSubject<(String, Bool)>(value: ("More", true))
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        navigationSetting()
        diffableDataSourceSetting()
        pageSetting()
        collectionView.dataSource = diffableDataSources
    }
    
    private func navigationSetting() {
        self.navigationItem.title = "Cinely"
        self.navigationItem.rightBarButtonItem
        = UIBarButtonItem(image: Icons.heart?.withTintColor(Color.green.withAlphaComponent(0.6)),
                          style: .plain,
                          target: self,
                          action: #selector(moveToSearchDetail(_:)))
    }
    
    private func pageSetting() {
        pageControl.currentPageIndicatorTintColor = Color.green
        pageControl.pageIndicatorTintColor = Color.green.withAlphaComponent(0.6)
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
        pageControl.isHidden = true
    }
    
    override func addChild() {
        self.view.addSubview(collectionView)
        self.collectionView.addSubview(pageControl)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            
            pageControl.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: collectionView.topAnchor, constant: PagingHeaderCell.height - 8)
        ])
    }
    
    override func binding() {
        pageControl.rx.controlEvent(.valueChanged)
            .subscribe(with: self, onNext: { vc, value in
                let indexPath = IndexPath(item: vc.pageControl.currentPage, section: 0)
                vc.collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            })
            .disposed(by: disposeBag)
        
        moreButtonTapped
            .subscribe(with: self, onNext: { vc, _ in
                let origin = vc.isSynopsisSectionExpanded
                vc.isSynopsisSectionExpanded = !origin
                if vc.isSynopsisSectionExpanded {
                    vc.synopsisHeaderState.onNext(("Hide", true))
                } else {
                    vc.synopsisHeaderState.onNext(("More", true))
                }
                guard var snapshot = vc.diffableDataSources?.snapshot() else { return }
                let synopsisItems = snapshot.itemIdentifiers(inSection: .synopsis)
                snapshot.reconfigureItems(synopsisItems)
                vc.diffableDataSources?.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)
        
        let output = detailViewModel.transform(input: .init())
        
        output.movieDetailModels
            .drive(with: self, onNext: { vc, sectionAndItems in
                vc.apply(sectionAndModels: sectionAndItems)
            })
            .disposed(by: disposeBag)
    }
    
    private func apply(sectionAndModels: [CinemaDetailViewModel.DetailSectionAndItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<MovieDetailSection, MovieDetailItem>()
        
        for sectionAndModel in sectionAndModels {
            let section = sectionAndModel.section
            let items = sectionAndModel.items
            snapshot.appendSections([section])
            snapshot.appendItems(items, toSection: section)
            
            if section == .pagingHeader {
                pageControl.numberOfPages = items.count
            }
        }
        
        self.diffableDataSources.apply(snapshot) { [weak self] in
            self?.pageControl.isHidden = sectionAndModels.isEmpty
        }
    }
    
    @objc
    private func moveToSearchDetail(_ sender: Any) {
        let searchVC = CinemaMovieSearchVIewController()
        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    private func pageControllSetting(_ pagingHeaderSection: NSCollectionLayoutSection) {
        pagingHeaderSection.visibleItemsInvalidationHandler = { [weak self] visible, contentOffset, environment in
            let currentPage = Int(max(0, round(contentOffset.x / environment.container.contentSize.width)))
            let isHorizonTalScroll = environment.container.contentSize.width >= environment.container.contentSize.height
            if isHorizonTalScroll {
                self?.pageControl.currentPage = currentPage
            }
        }
    }
}

extension CinemaDetailViewController {
    func compositionalLayout() -> UICollectionViewCompositionalLayout {
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .vertical
        config.interSectionSpacing = 6
        return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] section, environment in
            guard let self, let dataSource = self.diffableDataSources else {
                return NSCollectionLayoutSection(group: .init(layoutSize: .init(widthDimension: .absolute(0), heightDimension: .absolute(0))))
            }
            
            let section = dataSource.snapshot().sectionIdentifiers[section]
            
            switch section {
            case .pagingHeader:
                let pagingHeaderSection = CinemaDetailCollectionView.pagingHeaderSection()
                self.pageControllSetting(pagingHeaderSection)
                return pagingHeaderSection
            case .synopsis:
                return CinemaDetailCollectionView.synopsisSection()
            case .casts:
                return CinemaDetailCollectionView.castSection()
            }
        }, configuration: config)
    }
    
    fileprivate func diffableDataSourceSetting() {
        diffableDataSources = UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            switch item {
            case let .pagingHeader(model):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingHeaderCell.id, for: indexPath) as? PagingHeaderCell else {
                    return UICollectionViewCell()
                }
                cell.set(filePath: model.file_path)
                return cell
                
            case let .synopsis(description):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SynopsisContentCell.id, for: indexPath) as? SynopsisContentCell else {
                    return UICollectionViewCell()
                }
                cell.set(description: description, isSynopsisSectionExpanded: self?.isSynopsisSectionExpanded)
                return cell
                
            case let .casts(cast):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.id, for: indexPath) as? CastCell else {
                    return UICollectionViewCell()
                }
                cell.set(cast: cast)
                return cell
            }
        }
        
        diffableDataSources.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard let self else { return nil }
            
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: SectionHeaderView.id,
                        for: indexPath) as! SectionHeaderView
                    
                    header.setTitle(indexPath.section == 1 ? "Synopsis" : "Cast")
                    
                    if indexPath.section == 1 {
                        header.setTitleBinding(observable: synopsisHeaderState.asObservable())
                        
                        header.deleteButton.rx.tap
                            .bind(to: self.moreButtonTapped)
                            .disposed(by: header.disposeBag)
                    }
                    header.setDeleteButtonHidden(indexPath.section != 1)
                    
                    return header
                }
            }
            
            if kind == UICollectionView.elementKindSectionFooter && indexPath.section == 0 {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: BackDropFooterView.id, for: indexPath
                ) as! BackDropFooterView
                
                // guard let dataSource = self.diffableDataSources else {
                //     return UICollectionReusableView()
                // }
                
                footer.set(
                    date: self.movieModel.releaseDate,
                    rating: self.movieModel.voteAverage,
                    genres: self.movieModel.genres.joined(separator: ", ")
                )
                // let sectionIdentifier = dataSource.snapshot().sectionIdentifiers[indexPath.section]
                // let itemsInSection = dataSource.snapshot().itemIdentifiers(inSection: sectionIdentifier)
                // if let firstItem = itemsInSection.first {
                //
                //     if case let .pagingHeader(movieDetailModel) = firstItem {
                //         footer.set(
                //             date: movieDetailModel.movieModel.releaseDate,
                //             rating: movieDetailModel.movieModel.voteAverage,
                //             genres: movieDetailModel.movieModel.genres.joined(separator: ", ")
                //         )
                //     }
                // }
                return footer
            }
            return nil
        }
    }
}
