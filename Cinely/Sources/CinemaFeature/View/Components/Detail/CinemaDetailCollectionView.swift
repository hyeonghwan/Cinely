//
//  CinemaDetailCollectionView.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class CinemaDetailCollectionView: BaseCollectiionView {
    
    convenience init(layout: UICollectionViewCompositionalLayout) {
        self.init(frame: .zero, collectionViewLayout: layout)
        self.backgroundColor = Color.black
        self.register(SectionHeaderView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                      withReuseIdentifier: SectionHeaderView.id)
        self.register(BackDropFooterView.self,
                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                      withReuseIdentifier: BackDropFooterView.id)
        self.register(CastCell.self, forCellWithReuseIdentifier: CastCell.id)
        self.register(PagingHeaderCell.self, forCellWithReuseIdentifier: PagingHeaderCell.id)
        self.register(SynopsisContentCell.self, forCellWithReuseIdentifier: SynopsisContentCell.id)
        self.showsVerticalScrollIndicator = false
    }
    
    static func pagingHeaderSection() -> NSCollectionLayoutSection {
        let sectionFooter = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionFooter,
                                                                        alignment: .bottom)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(PagingHeaderCell.width),
                                              heightDimension: .absolute(PagingHeaderCell.height))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: itemSize.heightDimension)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionFooter]
        section.orthogonalScrollingBehavior = .groupPaging
        return section
    }
    
    static func synopsisSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemSize.widthDimension, heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        return section
    }
    
    static func castSection() -> NSCollectionLayoutSection {
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1),
                                                                                          heightDimension: .estimated(50)),
                                                                        elementKind: UICollectionView.elementKindSectionHeader,
                                                                        alignment: .top)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(UIScreen.main.bounds.width), heightDimension: .absolute(58))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: itemSize.widthDimension, heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        return section
    }
}
