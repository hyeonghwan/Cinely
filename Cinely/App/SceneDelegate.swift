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
        window.rootViewController = OnboardingViewController()
        Thread.sleep(forTimeInterval: 2)
        self.window = window
        self.window?.makeKeyAndVisible()
    }
}
