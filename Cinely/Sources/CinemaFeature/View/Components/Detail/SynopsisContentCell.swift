//
//  SynopsisContentCell.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class SynopsisContentCell: BaseCollectionViewCell, CellIdentifialble {
    
    private(set) var descriptionLabel = UILabel()
    
    
    override func addAttributes() {
        descriptionLabel.font = Font.regular14
        descriptionLabel.numberOfLines = 3
        descriptionLabel.lineBreakMode = .byTruncatingTail
        descriptionLabel.lineBreakStrategy = .hangulWordPriority
        descriptionLabel.textColor = Color.white
    }
    
    override func addChild() {
        self.contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    func set(description: String, isSynopsisSectionExpanded: Bool?) {
        self.descriptionLabel.text = description
        self.descriptionLabel.numberOfLines = (isSynopsisSectionExpanded ?? false) ? 0 : 3
    }
}
