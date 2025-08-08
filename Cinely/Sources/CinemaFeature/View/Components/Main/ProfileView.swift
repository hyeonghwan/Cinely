//
//  ProfileView.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

typealias ProfileView = ProfileContainerCell.ProfileView

final class ProfileContainerCell: BaseCollectionViewCell, CellIdentifialble {
    private(set) var profileHeaderView = ProfileView()
    
    override func addChild() {
        self.contentView.addSubview(profileHeaderView)
        profileHeaderView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let height = profileHeaderView.heightAnchor.constraint(equalToConstant: 100)
        height.priority = .defaultLow
        height.isActive = true
        NSLayoutConstraint.activate([
            profileHeaderView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 12),
            profileHeaderView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            profileHeaderView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -12)
        ])
    }
    
    final class ProfileView: BaseView {
        private(set) var nicknameLabel   = UILabel()
        private(set) var signUpDateLabel = UILabel()
        private(set) var angleImageView  = UIButton()
        private(set) var movieLikeBoxButton  = UIButton()
        
        func set(with user: User) {
            self.nicknameLabel.text = user.nickname
            self.signUpDateLabel.text = user.signUpDate
            let text = String(user.likeCount) + "개의 무비박스 보관중"
            self.movieLikeBoxButton.setAttributedTitle(
                NSAttributedString(string: "\(text)",
                                   attributes: [.font : Font.semiBold17, .foregroundColor : Color.white]),
                for: .normal
            )
        }
        
        override func addAttributes() {
            self.backgroundColor = Color.white.withAlphaComponent(0.1)
            self.layer.cornerRadius = 12
            
            nicknameLabel.textColor = Color.white
            nicknameLabel.text = "달콤한 기모청바지"
            nicknameLabel.font = Font.semiBold24
            
            signUpDateLabel.textColor = Color.lightGray
            signUpDateLabel.text = "25.06.24 가입"
            signUpDateLabel.font = Font.light12
            
            angleImageView.setImage(Icons.forword, for: .normal)
            angleImageView.tintColor = Color.lightGray
            
            movieLikeBoxButton.backgroundColor = Color.green.withAlphaComponent(0.6)
            movieLikeBoxButton.setTitleColor(Color.white, for: .normal)
            movieLikeBoxButton.setAttributedTitle(
                NSAttributedString(string: "0개의 무비박스 보관중",
                                   attributes: [.font : Font.semiBold17,
                                                .foregroundColor : Color.white]),
                for: .normal
            )
            movieLikeBoxButton.layer.cornerRadius = 8
            
            addLayout()
        }
        
        override func addChild() {
            self.addSubview(nicknameLabel)
            self.addSubview(signUpDateLabel)
            self.addSubview(angleImageView)
            self.addSubview(movieLikeBoxButton)
            
            nicknameLabel.translatesAutoresizingMaskIntoConstraints = false
            signUpDateLabel.translatesAutoresizingMaskIntoConstraints = false
            angleImageView.translatesAutoresizingMaskIntoConstraints = false
            movieLikeBoxButton.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func addLayout() {
            nicknameLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
            NSLayoutConstraint.activate([
                nicknameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
                nicknameLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                nicknameLabel.trailingAnchor.constraint(lessThanOrEqualTo: signUpDateLabel.leadingAnchor, constant: -8),
                
                angleImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
                angleImageView.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
                angleImageView.widthAnchor.constraint(equalToConstant: 25),
                angleImageView.heightAnchor.constraint(equalToConstant: 25),
                
                signUpDateLabel.trailingAnchor.constraint(equalTo: angleImageView.leadingAnchor),
                signUpDateLabel.centerYAnchor.constraint(equalTo: nicknameLabel.centerYAnchor),
                
                movieLikeBoxButton.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 24),
                movieLikeBoxButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                movieLikeBoxButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
                movieLikeBoxButton.heightAnchor.constraint(equalToConstant: 44),
                movieLikeBoxButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
            ])
        }
    }
}


#if canImport(RxSwift)
import RxSwift

extension ProfileView {
    var binder: Binder<User> {
        Binder<User>(self) { view, user in
            view.set(with: user)
        }
    }
}
    
#endif
