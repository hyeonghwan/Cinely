//
//  TabBarCoordinator.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit

protocol TabBarCoordinator: Coordinator {
    var tabBarController: CustomTabBarController { get set }
}

final class DefaultTabBarCoordinator: TabBarCoordinator {
    weak var delegate: CoordinatorFinishDelegate?
    var tabBarController: CustomTabBarController
    var childCoordinators: [Coordinator] = []
    private var dependency: AppDependency
    
    init(dependency: AppDependency) {
        self.tabBarController = CustomTabBarController()
        self.dependency = dependency
    }

    func start() {
        let cinemaNav = UINavigationController()
        cinemaNav.tabBarItem = UITabBarItem(title: "CINEMA", image: Icons.popCorn, tag: 0)
        
        let upcomingVCNav = UINavigationController()
        upcomingVCNav.tabBarItem = UITabBarItem(title: "UPCOMING", image: Icons.filmFill, tag: 1)
        upcomingVCNav.setViewControllers([UpcomingViewController()], animated: false)
        
        let profileSettingNav = UINavigationController()
        profileSettingNav.tabBarItem = UITabBarItem(title: "PROFILE", image: Icons.personCircle, tag: 1)
        
        let navigations = [cinemaNav, upcomingVCNav, profileSettingNav]
        tabBarController.tabBar.tintColor = Color.green
        tabBarController.setViewControllers(navigations, animated: false)
        tabBarController.selectedIndex = 0
        
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .black
        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
        
        startTabCoordinator(navigationControllers: navigations)
    }

    private func startTabCoordinator(navigationControllers: [UINavigationController]) {
        let cinemaMainCoordinator = DefaultCinemaMainCoordinator(
            rootViewController: navigationControllers[0],
            dependency: dependency
        )
        
        let profileSettingCoordinator = DefaultProfileSettingCoordinator(
            rootViewController: navigationControllers[2],
            dependency: dependency
        )
        
        cinemaMainCoordinator.delegate = self
        childCoordinators.append(cinemaMainCoordinator)
        cinemaMainCoordinator.start()
        
        profileSettingCoordinator.delegate = self
        childCoordinators.append(profileSettingCoordinator)
        profileSettingCoordinator.start()
    }
}

extension DefaultTabBarCoordinator: CoordinatorFinishDelegate {
    func didFinish(childCoordinator: any Coordinator) {
        if childCoordinator is ProfileSettingCoordinator {
            self.childCoordinators.removeAll()
            self.delegate?.didFinish(childCoordinator: self)
        }
    }
}

