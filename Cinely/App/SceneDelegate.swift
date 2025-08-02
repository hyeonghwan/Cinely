//
//  SceneDelegate.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow()
        window.windowScene = windowScene
        
        let cinemaMainVC = CinemaMainViewController()
        cinemaMainVC.tabBarItem = UITabBarItem(title: "CINEMA", image: Icons.popCorn, tag: 0)
        let cinemaNav = UINavigationController(rootViewController: cinemaMainVC)
        
        
        let upcomingVC = UpcomingViewController()
        upcomingVC.tabBarItem = UITabBarItem(title: "UPCOMING", image: Icons.filmFill, tag: 1)
        let upcomingVCNav = UINavigationController(rootViewController: upcomingVC)
        
        
        let profileSettingVC = ProfileSettingViewController()
        profileSettingVC.tabBarItem = UITabBarItem(title: "PROFILE", image: Icons.personCircle, tag: 1)
        
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = Color.green
        tabBarController.setViewControllers([cinemaNav, upcomingVCNav, profileSettingVC], animated: false)
        
        window.rootViewController = tabBarController
        
        // Thread.sleep(forTimeInterval: 2)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}

final class UpcomingViewController: BaseViewController {
    
    override func addAttributes() {
        self.view.backgroundColor = Color.black
    }
}

final class ProfileSettingViewController: BaseViewController {
    override func addAttributes() {
        self.view.backgroundColor = Color.black
    }
}
