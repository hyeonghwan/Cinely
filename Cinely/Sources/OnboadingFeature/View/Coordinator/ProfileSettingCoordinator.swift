//
//  ProfileSettingCoordinator.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit

protocol ProfileSettingCoordinator: Coordinator {
    func signOut()
}

final class DefaultProfileSettingCoordinator: ProfileSettingCoordinator, NicknamePresentCoordinator {
    var childCoordinators: [any Coordinator] = []
    var rootViewController: UINavigationController
    weak var delegate: CoordinatorFinishDelegate?
    var dependency: AppDependency
    lazy var changeNicknameViewModel = ChangeNickNameViewModel(appState: dependency.appState)
    let presentNavigationController = UINavigationController()
    
    init(rootViewController: UINavigationController, dependency: AppDependency) {
        self.rootViewController = rootViewController
        self.dependency = dependency
    }
    
    func start() {
        let profileViewController = ProfileSettingViewController.create(
            appState: dependency.appState,
            coordinator: self
        )
        rootViewController.setViewControllers([profileViewController], animated: true)
    }
    
    func signOut() {
        delegate?.didFinish(childCoordinator: self)
    }
    
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
