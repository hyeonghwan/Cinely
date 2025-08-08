//
//  CinemaCollectionView.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

typealias MainCollectionSection = CinemaCollectionView.Section
typealias MainHashableItem = CinemaCollectionView.Item

final class CinemaCollectionView: BaseCollectiionView {
    
    enum Section: Int {
        case header = 0
        case recentSearchResult
        case todayMovies
    }
    
    enum Item: Hashable {
        case user(User)
        case recentSearch(RecentSearchModel)
        case todayMovie(TodayMovieModel)
        case errorTodayMovie(ErrorMessage)
        case emptyRecentSearch
    }
    
    convenience init(layout: UICollectionViewCompositionalLayout) {
        self.init(frame: .zero, collectionViewLayout: layout)
        self.backgroundColor = Color.black
        self.register(ProfileContainerCell.self,
                      forCellWithReuseIdentifier: ProfileContainerCell.id)
        self.register(SectionHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: SectionHeaderView.id)
        self.register(RecentSearchResultCell.self,
                      forCellWithReuseIdentifier: RecentSearchResultCell.id)
        self.register(RecentSearchEmptyCell.self,
                      forCellWithReuseIdentifier: RecentSearchEmptyCell.id)
        self.register(TodayMovieItemCell.self,
                      forCellWithReuseIdentifier: TodayMovieItemCell.id)
        self.register(ErrorRetryCell.self,
                      forCellWithReuseIdentifier: ErrorRetryCell.id)
        self.showsVerticalScrollIndicator = false
    }
    
    static func headerSection() -> NSCollectionLayoutSection {
        let itemSize =  NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width), heightDimension: .estimated(150))
        let item =      NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let group =     NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section =   NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        return section
    }
    
    static func emptyResultSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        let itemSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(35))
        let item =      NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group =     NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section =   NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        section.orthogonalScrollingBehavior = .none
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)
        return section
    }
    
    static func recentSearchSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        let itemSize =  NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: .estimated(50))
        let item =      NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: itemSize.heightDimension)
        let group =     NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section =   NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 6
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)
        return section
    }
    
    static func errorMovieSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        let itemSize =  NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(UIScreen.main.bounds.height * 0.6))
        let item =      NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: itemSize.heightDimension)
        let group =     NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section =   NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .none
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 44, leading: 12, bottom: 12, trailing: 12)
        return section
    }
    
    static func todayMovieSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(UIScreen.main.bounds.height * 0.6))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.6), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 12, trailing: 12)
        return section
    }
}
