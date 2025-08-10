//
//  CinemaMainCoordinator.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit

protocol CinemaMainCoordinator: Coordinator {
    func moveToDetail(_ movieState: TodayMovieModel)
    func moveToSearch(word: String)
}

extension CinemaMainCoordinator {
    func moveToSearch(word: String = "") {
        self.moveToSearch(word: word)
    }
}

protocol NicknamePresentCoordinator: Coordinator {
    func presentNicknameSetting(userNickName: String)
    func pushNicknameDetailEdit()
    func dismissPresented()
}

final class DefaultCinemaMainCoordinator: CinemaMainCoordinator, NicknamePresentCoordinator {
    var childCoordinators: [any Coordinator] = []
    
    var rootViewController: UINavigationController
    
    weak var delegate: CoordinatorFinishDelegate?
    
    var dependency: AppDependency
    
    lazy var changeNicknameViewModel = ChangeNickNameViewModel(appState: dependency.appState)
        
    init(rootViewController: UINavigationController, dependency: AppDependency) {
        self.rootViewController = rootViewController
        self.dependency = dependency
    }
    
    func start() {
        let cinemaMainViewController = CinemaMainViewController.create(
            with: CinemaMainViewModel(
                dependency: CinemaMainViewModel.Dependency(
                    appState: dependency.appState,
                    appStorage: dependency.appStorage,
                    trendingMovieProvider: DefaultTrendingMovieProvider(
                        networkManager: dependency.networkManager
                    )
                )
            ),
            coordinator: self
        )
        rootViewController.setViewControllers([cinemaMainViewController], animated: false)
    }
    
    func moveToDetail(_ movieState: TodayMovieModel) {
        let detailVC = CinemaDetailViewController.create(
            with: CinemaDetailViewModel(
                dependency: .init(
                    appState: dependency.appState,
                    appStorage: dependency.appStorage,
                    movieImageProvider: DefaultMovieImageProvider(
                        networkManager: dependency.networkManager
                    ),
                    movieState: .init(movieModel: movieState)
                )
            )
        )
        detailVC.navigationItem.backButtonTitle = ""
        rootViewController.pushViewController(detailVC, animated: true)
    }
    
    func moveToSearch(word: String = "") {
        let searchVC = CinemaMovieSearchVIewController.create(
            with: CinemaSearchViewModel(
                dependency: .init(
                    appState: dependency.appState,
                    appStorage: dependency.appStorage,
                    movieSearchProvider: DefaultMovieSearchProvider(
                        networkManager: dependency.networkManager
                    ),
                    word: word
                )
            ),
            coordinator: self
        )
        searchVC.hidesBottomBarWhenPushed = true
        rootViewController.pushViewController(searchVC, animated: true)
    }
    
    let presentNavigationController = UINavigationController()
    
    func presentNicknameSetting(userNickName: String) {
        let editViewController = NicknameEditViewController.create(
            coordinator: self,
            viewModel: changeNicknameViewModel,
            userNickName: userNickName
        )
        presentNavigationController.setViewControllers([editViewController], animated: false)
        rootViewController.present(presentNavigationController, animated: true)
    }
    
    func pushNicknameDetailEdit() {
        let editViewController = NicknameDetailEditViewController.create(
            coordinator: self,
            viewModel: changeNicknameViewModel
        )
        presentNavigationController.pushViewController(editViewController, animated: true)
    }
    
    func dismissPresented() {
        self.rootViewController.dismiss(animated: true)
    }
}

