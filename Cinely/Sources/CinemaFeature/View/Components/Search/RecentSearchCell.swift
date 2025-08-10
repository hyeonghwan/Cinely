//
//  CinemaSearchSuggestionTableView.swift
//  Cinely
//
//  Created by hwan on 8/9/25.
//

import UIKit
import HwanKit
import RxSwift

final class RecentSearchCell: BaseTableViewCell, CellIdentifialble {
    private let iconImageView = UIImageView()
    private let recentWordLabel = UILabel()
    private(set) var deleteButton = UIButton()
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func set(word: String) {
        recentWordLabel.text = word
    }
    
    override func addChild() {
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(recentWordLabel)
        self.contentView.addSubview(deleteButton)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        recentWordLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addAttributes() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        recentWordLabel.textColor = Color.white
        recentWordLabel.font = Font.semiBold14
        recentWordLabel.numberOfLines = 1
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = Color.white
        iconImageView.image = Icons.clock
        
        deleteButton.tintColor = Color.white
        deleteButton.setImage(Icons.xmark, for: .normal)
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            iconImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            iconImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            recentWordLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            recentWordLabel.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 24),
            deleteButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
