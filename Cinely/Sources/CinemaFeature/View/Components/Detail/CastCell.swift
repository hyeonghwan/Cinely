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
        castImageView.layer.cornerRadius = 30
        castImageView.clipsToBounds = true
        
        actorNameLabel.font = Font.bold17
        roleNameLabel.font = Font.thin14
        actorNameLabel.textColor = Color.white
        roleNameLabel.textColor = Color.mediumGray.withAlphaComponent(0.6)
    }
    
    override func addChild() {
        self.addSubview(castImageView)
        self.addSubview(actorNameLabel)
        self.addSubview(roleNameLabel)
        castImageView.translatesAutoresizingMaskIntoConstraints = false
        actorNameLabel.translatesAutoresizingMaskIntoConstraints = false
        roleNameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let imageHeight = castImageView.heightAnchor.constraint(equalToConstant: 60)
        imageHeight.isActive = true
        imageHeight.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            castImageView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 4),
            castImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            castImageView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -4),
            castImageView.widthAnchor.constraint(equalToConstant: 60),
            
            actorNameLabel.centerYAnchor.constraint(equalTo: castImageView.centerYAnchor),
            actorNameLabel.leadingAnchor.constraint(equalTo: castImageView.trailingAnchor, constant: 8),
            
            roleNameLabel.centerYAnchor.constraint(equalTo: actorNameLabel.centerYAnchor),
            roleNameLabel.leadingAnchor.constraint(equalTo: actorNameLabel.trailingAnchor, constant: 8),
            roleNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.contentView.trailingAnchor, constant: -8)
        ])
    }
    
    func set(cast: Cast) {
        // self.castImageView.setKFImage(image: cast.postImageView, size: CGSize(width: 60, height: 60))
        self.castImageView.setDefaultImage(image: UIImage.hyeonghwan)
        self.actorNameLabel.text = cast.actorName
        self.roleNameLabel.text = cast.roleName
    }
}


