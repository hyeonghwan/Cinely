//
//  CastCell.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class CastCell: BaseCollectionViewCell, CellIdentifialble {
    
    private let castImageView = MovieImageView()
    private let actorNameLabel = UILabel()
    private let roleNameLabel = UILabel()
    
    override func addAttributes() {
        castImageView.contentMode = .scaleAspectFill
        castImageView.layer.cornerRadius = 25
        castImageView.clipsToBounds = true
        
        actorNameLabel.font = Font.bold14
        roleNameLabel.font = Font.thin12
        actorNameLabel.textColor = Color.white
        roleNameLabel.textColor = Color.mediumGray.withAlphaComponent(0.6)
        roleNameLabel.textAlignment = .left
        roleNameLabel.minimumScaleFactor = 0.7
        roleNameLabel.numberOfLines = 3
    }
    
    override func addChild() {
        self.contentView.addSubview(castImageView)
        self.contentView.addSubview(actorNameLabel)
        self.contentView.addSubview(roleNameLabel)
        castImageView.translatesAutoresizingMaskIntoConstraints = false
        actorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        roleNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let imageHeight = castImageView.heightAnchor.constraint(equalToConstant: 50)
        imageHeight.isActive = true
        imageHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            castImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            castImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            castImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            castImageView.widthAnchor.constraint(equalToConstant: 50),
            
            actorNameLabel.centerYAnchor.constraint(equalTo: castImageView.centerYAnchor),
            actorNameLabel.leadingAnchor.constraint(equalTo: castImageView.trailingAnchor, constant: 8),
            
            roleNameLabel.centerYAnchor.constraint(equalTo: actorNameLabel.centerYAnchor),
            roleNameLabel.leadingAnchor.constraint(equalTo: actorNameLabel.trailingAnchor, constant: 8),
            roleNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func set(cast: Cast) {
        self.castImageView.setKFImage(image: cast.profileImageURL, size: CGSize(width: 50, height: 50))
        self.actorNameLabel.text = cast.actorName
        self.roleNameLabel.text = cast.roleName
    }
}


