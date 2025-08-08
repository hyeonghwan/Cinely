//
//  AppCoordinator.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit

final class AppCoordinator: Coordinator {
    private var window: UIWindow
    private var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    let dependency: AppDependency
    
    init(window: UIWindow, dependency: AppDependency) {
        self.window = window
        self.navigationController = UINavigationController()
        self.dependency = dependency
    }

    func start() {
        if !Storage.didFinishOnboarding {
            startOnboardingCoordinator()
        } else {
            startTabBarCoordinator(dependency: dependency)
        }
    }
    
    private func startOnboardingCoordinator() {
        let onboardingCoordinator = DefaultOnboardingCoordinator(
            rootViewController: navigationController,
            dependency: OnboardingFeatureViewModel(
                appState: dependency.appState
            )
        )
        onboardingCoordinator.delegate = self
        childCoordinators.append(onboardingCoordinator)
        onboardingCoordinator.start()
        window.rootViewController = navigationController
    }
    
    private func startTabBarCoordinator(dependency: AppDependency) {
        let tabBarCoordinator = DefaultTabBarCoordinator(dependency: dependency)
        tabBarCoordinator.delegate = self
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
        window.rootViewController = tabBarCoordinator.tabBarController
    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func didFinish(childCoordinator: any Coordinator) {
        childCoordinators.removeAll(where: { $0 === childCoordinator })
        
        if childCoordinator is TabBarCoordinator {
            Storage.didFinishOnboarding = false
            startOnboardingCoordinator()
            return
        }
        
        if childCoordinator is OnboardingCoordinator {
            Storage.didFinishOnboarding = true
            startTabBarCoordinator(dependency: dependency)
            return
        }
    }
}
