//
//  CinemaSearchCollectionView.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

typealias CinemaSearchCell = CinemaSearchTableView.CinemaSearchCell
typealias CinemaEmptyCell = CinemaSearchTableView.CinemaEmptyCell

final class CinemaSearchTableView: BaseTableView {
    override func addAttributes() {
        self.register(
            RecentSearchCell.self,
            forCellReuseIdentifier: RecentSearchCell.id
        )
        self.register(
            CinemaSearchCell.self,
            forCellReuseIdentifier: CinemaSearchCell.id
        )
        self.register(
            CinemaEmptyCell.self,
            forCellReuseIdentifier: CinemaEmptyCell.id
        )
        self.register(
            RefreshCell.self,
            forCellReuseIdentifier: RefreshCell.id
        )
        self.register(
            LastEmptyCell.self,
            forCellReuseIdentifier: LastEmptyCell.id
        )
        self.register(
            SuggestionHeaderView.self,
            forHeaderFooterViewReuseIdentifier: SuggestionHeaderView.id
        )
        self.register(
            RecentSearchEmptyTableViewCell.self,
            forCellReuseIdentifier: RecentSearchEmptyTableViewCell.id
        )
    }
}

extension CinemaSearchTableView {
    final class CinemaEmptyCell: BaseTableViewCell, CellIdentifialble {
        private let label = UILabel()
        
        override func addAttributes() {
            label.font = Font.thin17
            label.textColor = Color.mediumGray.withAlphaComponent(0.5)
            label.textAlignment = .center
            label.text = "원하는 검색결과를 찾지 못했습니다"
        }
        
        override func addChild() {
            self.contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        override func addLayout() {
            let heightAnchor = label.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2)
            heightAnchor.priority = .defaultHigh
            
            heightAnchor.isActive = true
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: contentView.topAnchor),
                label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
            ])
        }
    }
}

import RxSwift

// MARK: Cinema Search TableView Cell
extension CinemaSearchTableView {
    final class CinemaSearchCell: BaseTableViewCell, CellIdentifialble {
        private let postImageView = MovieImageView()
        private let titleLabel = UILabel()
        private let dateLabel = UILabel()
        private let cinemaGenreList = CinemaGenreListCollectionView()
        private(set) var likeButton = LikeButton()
        private(set) var disposeBag = DisposeBag()
        
        func set(with model: TodayMovieModel) {
            postImageView.setKFImage(image: model.postImage, size: CGSize(width: 100, height: 100))
            titleLabel.text = model.title
            dateLabel.text = model.releaseDate.toFormattedString(current: "yyyy-MM-dd", after: "yyyy. MM. dd")
            likeButton.isSelected = model.favorite
            cinemaGenreList.setGenres(model.genres)
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            disposeBag = DisposeBag()
        }
        
        override func addAttributes() {
            postImageView.layer.cornerRadius = 5
            postImageView.contentMode = .scaleAspectFill
            postImageView.clipsToBounds = true
            titleLabel.font = Font.bold17
            titleLabel.textColor = Color.white
            titleLabel.numberOfLines = 2
            dateLabel.font = Font.light14
            dateLabel.textColor = Color.mediumGray.withAlphaComponent(0.5)
        }
        
        override func addChild() {
            self.contentView.addSubview(postImageView)
            self.contentView.addSubview(titleLabel)
            self.contentView.addSubview(dateLabel)
            self.contentView.addSubview(cinemaGenreList)
            self.contentView.addSubview(likeButton)
            postImageView.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            dateLabel.translatesAutoresizingMaskIntoConstraints = false
            cinemaGenreList.translatesAutoresizingMaskIntoConstraints = false
            likeButton.translatesAutoresizingMaskIntoConstraints = false
        }

        override func addLayout() {
            let heightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 130)
            heightConstraint.priority = .defaultHigh
            heightConstraint.isActive = true
            
            titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            dateLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            
            NSLayoutConstraint.activate([
                postImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                postImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
                postImageView.widthAnchor.constraint(equalToConstant: 100),
                
                titleLabel.topAnchor.constraint(equalTo: postImageView.topAnchor),
                titleLabel.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                
                dateLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
                dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                
                cinemaGenreList.topAnchor.constraint(equalTo: dateLabel.bottomAnchor),
                cinemaGenreList.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor),
                cinemaGenreList.leadingAnchor.constraint(equalTo: postImageView.trailingAnchor, constant: 16),
                cinemaGenreList.trailingAnchor.constraint(equalTo: likeButton.leadingAnchor, constant: -12),
                
                likeButton.widthAnchor.constraint(equalToConstant: 30),
                likeButton.heightAnchor.constraint(equalToConstant: 30),
                
                likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
                likeButton.bottomAnchor.constraint(equalTo: postImageView.bottomAnchor)
            ])
        }
    }
}


// MARK: internal Genre List View - CinemaGenreListCollectionView
extension CinemaSearchTableView {
    private class CinemaGenreListCollectionView: BaseCollectiionView {
        private var strongDataSource: CustomDataSource!
        private var strongFlowDelegate: CustomFlowLayoutDelegate!
        convenience init() {
            self.init(frame: .zero, collectionViewLayout: TagCollectionViewFlowLayout())
            self.strongDataSource = CustomDataSource()
            self.strongFlowDelegate = CustomFlowLayoutDelegate()
            
            self.delegate = strongFlowDelegate
            self.dataSource = strongDataSource
            
            self.backgroundColor = .black
            self.register(
                TagCollectionViewCell.self,
                forCellWithReuseIdentifier: TagCollectionViewCell.id
            )
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.isUserInteractionEnabled = false
        }
        
        func setGenres(_ models: [String]) {
            self.strongDataSource.models = models
            self.reloadData()
        }
    }
    
    final class CustomDataSource: NSObject, UICollectionViewDataSource {
        var models: [String] = []
        
        convenience init(models: [String]) {
            self.init()
            self.models = models
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return models.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.id, for: indexPath) as? TagCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.set(genre: models[indexPath.row])
            return cell
        }
    }
    
    final class CustomFlowLayoutDelegate: NSObject, UICollectionViewDelegateFlowLayout {
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if let dataSource = collectionView.dataSource as? CustomDataSource {
                let itemWidth = (dataSource.models[indexPath.row] as NSString).boundingRect(
                    with: CGSize(width: CGFloat.greatestFiniteMagnitude, height: 30),
                    options: .usesLineFragmentOrigin,
                    attributes: [.font: CinemaSearchTableView.TagLabel.font],
                    context: nil
                ).width
                return CGSize(width: itemWidth + 8, height: 30)
            }
            return CGSize(width: 100, height: 30)
        }
    }
    
    private class TagCollectionViewCell: BaseCollectionViewCell, CellIdentifialble {
        private let genreLabel = TagLabel()
        
        override func addAttributes() {
            self.genreLabel.textColor = Color.white
            self.layer.cornerRadius = 3
            self.backgroundColor = Color.mediumGray.withAlphaComponent(0.6)
        }
        
        override func addChild() {
            self.contentView.addSubview(genreLabel)
            genreLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        override func addLayout() {
            genreLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            NSLayoutConstraint.activate([
                genreLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 3),
                genreLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 4),
                genreLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -4),
                genreLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -3)
            ])
        }
        
        func set(genre: String) {
            self.genreLabel.text = genre
        }
    }
    
    final class TagLabel: UILabel {
        static let font = Font.thin12
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            addLayout()
            self.transform = CGAffineTransform(scaleX: 1, y: -1)
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        private func addLayout() {
            self.textAlignment = .center
            self.font = Self.font
        }
    }
}

