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

import Kingfisher


final class CinemaDetailViewController: BaseViewController {
    
    static func create(with dependency: CinemaDetailViewModel) -> CinemaDetailViewController {
        let vc = CinemaDetailViewController()
        vc.detailViewModel = dependency
        vc.movieModel = dependency.movieState.movieModel
        vc.isFavoriteTapped = BehaviorRelay<Bool>(value: vc.movieModel.favorite)
        return vc
    }
    
    private var diffableDataSources: UICollectionViewDiffableDataSource<MovieDetailSection, MovieDetailItem>!
    fileprivate var detailViewModel: CinemaDetailViewModel!
    private lazy var collectionView    = CinemaDetailCollectionView(layout: compositionalLayout())
    private let pageControl = UIPageControl()
    private var indicatorContainerView = IndicatorContainerView()
    
    private var movieModel: TodayMovieModel!
    private var isSynopsisSectionExpanded: Bool = false
    private var isFavoriteTapped: BehaviorRelay<Bool>!
    private var disposeBag = DisposeBag()
    
    deinit {
        KingfisherManager.shared.cache.clearMemoryCache()
    }
    
    // MARK: EVENT
    private let moreButtonTapped = PublishRelay<Void>()
    private let synopsisHeaderState = BehaviorRelay<(String, Bool)>(value: ("More", true))
    private let viewDidLoad = PublishRelay<Void>()
    private let retryTrigger = PublishRelay<Void>()
    private let reloadComplete = PublishRelay<Void>()
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        navigationSetting()
        diffableDataSourceSetting()
        pageSetting()
        setIndicator(indicator: indicatorContainerView)
        collectionView.dataSource = diffableDataSources
    }
    
    private func navigationSetting() {
        let likeBarButtonItem = UIBarButtonItem(
            image: Icons.heart?.withTintColor(Color.green.withAlphaComponent(0.6)),
            style: .plain,
            target: nil,
            action: nil
        )
        
        self.navigationItem.rightBarButtonItem = likeBarButtonItem

        isFavoriteTapped
            .subscribe(onNext: { [weak likeBarButtonItem] isSelected in
                if let likeBarButtonItem {
                    let icon = isSelected ? Icons.heartFill : Icons.heart
                    likeBarButtonItem.image = icon?.withTintColor(Color.green.withAlphaComponent(0.6))
                }
            })
            .disposed(by: disposeBag)
        
        likeBarButtonItem.rx.tap
            .withLatestFrom(isFavoriteTapped)
            .map { value in !value }
            .bind(to: isFavoriteTapped)
            .disposed(by: disposeBag)
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
        viewAction()
        
        let output = detailViewModel.transform(input: .init(
            viewDidLoad: viewDidLoad.asObservable(),
            retryTrigger: retryTrigger.asObservable(),
            isFavoriteTapped: isFavoriteTapped.asObservable(),
            reloadComplete: reloadComplete.asObservable()
        ))
        
        outputBinding(output: output)
        
        viewDidLoad.accept(())
    }
    
    private func viewAction() {
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
                    vc.synopsisHeaderState.accept(("Hide", true))
                } else {
                    vc.synopsisHeaderState.accept(("More", true))
                }
                guard var snapshot = vc.diffableDataSources?.snapshot() else { return }
                let synopsisItems = snapshot.itemIdentifiers(inSection: .synopsis)
                snapshot.reconfigureItems(synopsisItems)
                
                vc.diffableDataSources?.apply(snapshot, animatingDifferences: false)
            })
            .disposed(by: disposeBag)
    }
    
    private func outputBinding(output: CinemaDetailViewModel.Output) {
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
        
        output.movieDetailModels
            .filter { !$0.isEmpty }
            .drive(with: self, onNext: { vc, sectionAndItems in
                vc.apply(sectionAndModels: sectionAndItems)
            })
            .disposed(by: disposeBag)
        
        output.lazyLoadingFavorite
            .skip(1)
            .drive(with: self, onNext: { vc, isFavorite in
                let icon = isFavorite ? Icons.heartFill : Icons.heart
                vc.navigationItem.rightBarButtonItem?.image
                =
                icon?.withTintColor(Color.green.withAlphaComponent(0.6))
            })
            .disposed(by: disposeBag)
        
        output.errorAlertTrigger
            .map { [weak self] errMessage in
                var errMessage = errMessage
                errMessage.retry = { self?.retryTrigger.accept(()) }
                return errMessage
            }
            .drive(errorRetryAlert)
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
        
        self.reloadComplete.accept(())
        
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
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: SectionHeaderView.id,
                        for: indexPath
                    ) as! SectionHeaderView
                    
                    header.setTitle(indexPath.section == 1 ? "Synopsis" : "Cast")
                    
                    if indexPath.section == 1 {
                        self?.synopsisHeaderState
                            .subscribe(with: header, onNext: { _header, tuple in
                                let (text, _) = tuple
                                _header.deleteButton
                                    .setAttributedTitle(
                                        NSAttributedString(string: text, attributes: [.foregroundColor : Color.green]),
                                        for: .normal
                                    )
                            })
                            .disposed(by: header.disposeBag)
                        
                        if let self {
                            header.deleteButton.rx.tap
                                .bind(to: self.moreButtonTapped)
                                .disposed(by: header.disposeBag)
                        }
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
                if let self {
                    footer.set(
                        date: self.movieModel.releaseDate,
                        rating: self.movieModel.voteAverage,
                        genres: self.movieModel.genres.joined(separator: ", ")
                    )
                }
                return footer
            }
            return nil
        }
    }
}
