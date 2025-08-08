//
//  TodayMovieCell.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import RxSwift

final class TodayMovieItemCell: BaseCollectionViewCell, CellIdentifialble {
    private let movieImageView   = MovieImageView()
    private let titleLabel       = UILabel()
    private let descriptionLabel = UILabel()
    private(set) var heartButton      = LikeButton()
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func addAttributes() {
        movieImageView.contentMode = .scaleAspectFill
        movieImageView.layer.cornerRadius = 12
        movieImageView.clipsToBounds = true
        
        // Test
        titleLabel.text = "기생충"
        movieImageView.backgroundColor = Color.white
        
        titleLabel.textColor = Color.white
        titleLabel.font = Font.bold24
        descriptionLabel.textColor = Color.white
        descriptionLabel.font = Font.light14
        descriptionLabel.numberOfLines = 3
    }
    
    override func addChild() {
        self.contentView.addSubview(movieImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(descriptionLabel)
        self.contentView.addSubview(heartButton)
        
        movieImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        heartButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        descriptionLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        descriptionLabel.setContentHuggingPriority(.required, for: .vertical)
        
        NSLayoutConstraint.activate([
            movieImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            movieImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            movieImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            movieImageView.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2 - 80),
            
            titleLabel.topAnchor.constraint(equalTo: movieImageView.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: heartButton.leadingAnchor, constant: -8),
            
            heartButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            heartButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            heartButton.widthAnchor.constraint(equalToConstant: 30),
            heartButton.heightAnchor.constraint(equalTo: heartButton.widthAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    func set(with model: TodayMovieModel) {
        self.movieImageView.setKFImage(
            image: model.postImage,
            size: CGSize(
                width: UIScreen.main.bounds.width - 50,
                height: UIScreen.main.bounds.height / 2 - 80
            )
        )
        self.titleLabel.text = model.title
        self.descriptionLabel.text = model.description
    }
}
