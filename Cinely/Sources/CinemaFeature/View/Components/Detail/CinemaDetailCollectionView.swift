//
//  CinemaDetailCollectionView.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

typealias CinemaDetailDataSource = CinemaDetailCollectionView.CinemaDetailDataSource

final class CinemaDetailCollectionView: BaseCollectiionView {
    enum Section {
        case pagingHeader([String])
        case synopsis(String)
        case casts([Cast])
    }
    
    convenience init(dataSource: CinemaDetailDataSource) {
        let compositionalLayout = dataSource.dataSourceCompositionalLayout()
        self.init(frame: .zero, collectionViewLayout: compositionalLayout)
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
        
        self.dataSource = dataSource
        self.showsVerticalScrollIndicator = false
    }
    
    final class CinemaDetailDataSource: NSObject, UICollectionViewDataSource {
        private(set) lazy var dataSource: [Section] = [
            .pagingHeader(["hyeonghwan", "hyeonghwan", "hyeonghwan", "hyeonghwan", "hyeonghwan", "hyeonghwan", "hyeonghwan"]),
            .synopsis("안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 안녕하세요 reset --hard..., 언제 복구 "),
            .casts([Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan"),
                    Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan"),
                    Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan"),
                    Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan"),
                    Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan"),
                    Cast(postImageView: "hyeonghwan", actorName: "형환", roleName: "park Hyeong Hwan")])
        ]
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return switch self.dataSource[section] {
            case let .pagingHeader(models):
                models.count
            case .synopsis:
                1
            case let .casts(casts):
                casts.count
            }
        }
        
        func numberOfSections(in collectionView: UICollectionView) -> Int {
            dataSource.count
        }
        
        func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
            if kind == UICollectionView.elementKindSectionHeader {
                if indexPath.section == 1 || indexPath.section == 2 {
                    let header = collectionView.dequeueReusableSupplementaryView(
                        ofKind: UICollectionView.elementKindSectionHeader,
                        withReuseIdentifier: SectionHeaderView.id,
                        for: indexPath) as! SectionHeaderView
                    
                    header.setTitle(indexPath.section == 1 ? "Synopsis" : "Cast")
                    header.setButtonTitle("More")
                    header.setDeleteButtonHidden(indexPath.section != 1)
                    return header
                }
            }
            
            if kind == UICollectionView.elementKindSectionFooter && indexPath.section == 0 {
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: UICollectionView.elementKindSectionFooter,
                    withReuseIdentifier: BackDropFooterView.id, for: indexPath
                ) as! BackDropFooterView
                
                footer.set()
                return footer
            }
            return UICollectionReusableView()
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            switch dataSource[indexPath.section] {
            case let .pagingHeader(models):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingHeaderCell.id, for: indexPath) as? PagingHeaderCell else {
                    return UICollectionViewCell()
                }
                cell.set(image: models[indexPath.row])
                return cell
                
            case let .synopsis(description):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SynopsisContentCell.id, for: indexPath) as? SynopsisContentCell else {
                    return UICollectionViewCell()
                }
                cell.set(description: description)
                return cell
                
            case let .casts(casts):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CastCell.id, for: indexPath) as? CastCell else {
                    return UICollectionViewCell()
                }
                cell.set(cast: casts[indexPath.row])
                return cell
            }
        }
        
        func dataSourceCompositionalLayout() -> UICollectionViewCompositionalLayout {
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.scrollDirection = .vertical
            config.interSectionSpacing = 6
            return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] section, environment in
                switch self?.dataSource[section] {
                case .pagingHeader:
                    Section.pagingHeaderSection()
                    
                case .synopsis:
                    Section.synopsisSection()
                    
                case .casts:
                    Section.castSection()
                default:
                    fatalError()
                }
            }, configuration: config)
        }
    }
}


extension CinemaDetailCollectionView.Section {
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
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: .absolute(76))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(150), heightDimension: itemSize.heightDimension)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 6
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
        return section
    }
}
