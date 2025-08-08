//
//  OnboardingCoordinator.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit


protocol OnboardingCoordinator: Coordinator {
    func pushToNicknameSettingVC()
    func pushToNicknameEditVC(title: String)
    func didFinish()
}

final class DefaultOnboardingCoordinator: OnboardingCoordinator {
    var rootViewController: UINavigationController
    var childCoordinators: [any Coordinator] = []
    weak var delegate: CoordinatorFinishDelegate?
    private var dependency: OnboardingFeatureViewModel
    
    init(rootViewController: UINavigationController, dependency: OnboardingFeatureViewModel) {
        self.rootViewController = rootViewController
        self.dependency = dependency
    }
    
    func start() {
        let onboardingVC = OnboardingViewController()
        onboardingVC.coordinator = self
        rootViewController.setViewControllers([onboardingVC], animated: false)
    }
    
    func pushToNicknameSettingVC() {
        let nicknameSettingViewController = NicknameSettingViewController.create(
            coordinator: self,
            viewModel: dependency
        )
        nicknameSettingViewController.coordinator = self
        nicknameSettingViewController.title = "닉네임 설정"
        rootViewController.pushViewController(nicknameSettingViewController, animated: true)
    }
    
    func pushToNicknameEditVC(title: String) {
        let nicknameDetailViewController = NicknameDetailViewController.create(
            coordinator: self,
            viewModel: dependency
        )
        nicknameDetailViewController.title = title
        nicknameDetailViewController.coordinator = self
        rootViewController.pushViewController(nicknameDetailViewController, animated: true)
    }
    
    
    func didFinish() {
        delegate?.didFinish(childCoordinator: self)
    }
}
