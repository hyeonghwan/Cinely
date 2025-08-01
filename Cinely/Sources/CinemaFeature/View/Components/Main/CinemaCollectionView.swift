//
//  CinemaCollectionView.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design


typealias CinemaDataSource = CinemaCollectionView.CinemaDataSource

final class CinemaCollectionView: BaseCollectiionView {
    enum Section {
        case header
        case recentSearchResult([SearchItem])
        case todayMovies([TodayMovieModel])
        
        static func headerSection() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width), heightDimension: .estimated(150))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .none
            return section
        }
        
        static func emptyResultSection() -> NSCollectionLayoutSection {
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                              heightDimension: .estimated(50)),
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(35))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            section.orthogonalScrollingBehavior = .none
            section.boundarySupplementaryItems = [sectionHeader]
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
            return section
        }
        
        static func recentSearchSection() -> NSCollectionLayoutSection {
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                              heightDimension: .estimated(50)),
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: .estimated(35))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = 6
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [sectionHeader]
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
            return section
        }
        
        static func todayMovieSection() -> NSCollectionLayoutSection {
            let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                              heightDimension: .estimated(50)),
                                                                            elementKind: UICollectionView.elementKindSectionHeader,
                                                                            alignment: .top)
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            
            section.interGroupSpacing = 16
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [sectionHeader]
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)
            return section
        }
    }
    
    final class CinemaDataSource: NSObject, UICollectionViewDataSource {
        var dummy: [SearchItem] { [.init(searchText: "현빈"), .init(searchText: "스파이더"), .init(searchText: "해리포터"), .init(searchText: "소방관"), .init(searchText: "크리스마스"), .init(searchText: "Print"), .init(searchText: "text"), .init(searchText: "textValue"), .init(searchText: "Print"), .init(searchText: "Print"), .init(searchText: "Print"), .init(searchText: "Print"), .init(searchText: "text"), .init(searchText: "textValue"), .init(searchText: "Print"), .init(searchText: "Print"), .init(searchText: "Print"), .init(searchText: "Print")] }
        
        private(set) lazy var dataSource: [Section] = [
            .header,
            .recentSearchResult(dummy),
            .todayMovies(TodayMovieModel.dummyList)
        ]
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch self.dataSource[section] {
            case .header:
                return 1
            case let .recentSearchResult(models):
                return models.count == 0 ? 1 : models.count
            case let .todayMovies(models):
                return models.count
            }
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            dataSource.count
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: RecentSearchHeader.id, for: indexPath) as! RecentSearchHeader
                    header.setTitle(indexPath.section == 1 ? "최근검색어" : "오늘의 영화")
                    header.setDeleteButtonHidden(indexPath.section != 1)
                    return header
                }
            }
            return UICollectionReusableView()
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch dataSource[indexPath.section] {
            case .header:
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileContainerCell.id, for: indexPath) as? ProfileContainerCell else {
                    return UICollectionViewCell()
                }
                return cell
                
            case let .recentSearchResult(items):
                if items.count == 0 {
                    guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchEmptyCell.id, for: indexPath) as? RecentSearchEmptyCell else {
                        return UICollectionViewCell()
                    }
                    return cell
                }
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentSearchResultCell.id, for: indexPath) as? RecentSearchResultCell else {
                    return UICollectionViewCell()
                }
                cell.setText(items[indexPath.row].searchText)
                return cell
                
            case let .todayMovies(todayMovieList):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayMovieItemCell.id, for: indexPath) as? TodayMovieItemCell else {
                    return UICollectionViewCell()
                }
                cell.set(with: todayMovieList[indexPath.row])
                return cell
            }
        }
        
        func dataSourceCompositionalLayout() -> UICollectionViewCompositionalLayout {
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .vertical
            config.interSectionSpacing = 6
            return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] section, environment in
                switch self?.dataSource[section] {
                case .header:
                    return Section.headerSection()
                    
                case let .recentSearchResult(items):
                    return items.count == 0 ? Section.emptyResultSection() : Section.recentSearchSection()
                    
                case .todayMovies:
                    return Section.todayMovieSection()
                default:
                    fatalError()
                }
            }, configuration: config)
        }
    }
    
    convenience init(dataSource: CinemaDataSource) {
        let compositionalLayout = dataSource.dataSourceCompositionalLayout()
        self.init(frame: .zero, collectionViewLayout: compositionalLayout)
        self.backgroundColor = Color.black
        self.register(ProfileContainerCell.self,
                      forCellWithReuseIdentifier: ProfileContainerCell.id)
        
        self.register(RecentSearchHeader.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: RecentSearchHeader.id)
        
        self.register(RecentSearchResultCell.self,
                      forCellWithReuseIdentifier: RecentSearchResultCell.id)
        
        self.register(RecentSearchEmptyCell.self,
                      forCellWithReuseIdentifier: RecentSearchEmptyCell.id)
        
        self.register(TodayMovieItemCell.self,
                      forCellWithReuseIdentifier: TodayMovieItemCell.id)
        self.dataSource = dataSource
        self.showsVerticalScrollIndicator = false
    }
}
