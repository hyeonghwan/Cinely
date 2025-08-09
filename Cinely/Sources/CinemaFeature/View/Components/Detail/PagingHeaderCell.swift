//
//  PagingHeaderCell.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design
import Kingfisher

final class PagingHeaderCell: BaseCollectionViewCell, CellIdentifialble {
    private let postImageView = MovieImageView()
    
    static let width = UIScreen.main.bounds.width
    static let height = UIScreen.main.bounds.width - 100
    
    override func addAttributes() {
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
    }
    
    override func addChild() {
        self.contentView.addSubview(postImageView)
        postImageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let heightAnchor = postImageView.heightAnchor.constraint(equalToConstant: Self.height)
        heightAnchor.isActive = true
        heightAnchor.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            postImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            postImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            postImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            postImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        ])
    }
    
    func set(filePath: String) {
        self.postImageView.setKFImage(image: filePath, size: CGSize(width: Self.width, height: Self.height))
    }
}
