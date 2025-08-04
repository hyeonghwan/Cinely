//
//  ProfileViewBinder.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation
import RxSwift
import RxCocoa

extension ProfileContainerCell {
    var binder: Binder<User> {
        Binder<User>(self) { view, user in
            view.profileHeaderView.nicknameLabel.text = user.nickname
            view.profileHeaderView.signUpDateLabel.text = user.signUpDate
            let text = String(user.likeCount) + "개의 무비박스 보관중"
            view.profileHeaderView.movieLikeBoxButton.setTitle(text, for: .normal)
        }
    }
}

extension TodayMovieItemCell {
    var binder: Binder<TodayMovieModel> {
        Binder<TodayMovieModel>(self) { view, model in
            view.set(with: model)
        }
    }
}

extension RecentSearchResultCell {
    var binder: Binder<RecentSearchModel> {
        Binder<RecentSearchModel>(self) { view, model in
            view.setText(model.word)
        }
    }
}
