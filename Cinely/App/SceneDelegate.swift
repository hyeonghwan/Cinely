//
//  SceneDelegate.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import RxSwift

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    private var appCoordinator: AppCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow()
        window.windowScene = windowScene
        let dependency = AppDependencyFactory.make()
        let appCoordinator = AppCoordinator(window: window, dependency: dependency)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
        window.makeKeyAndVisible()
    }
}

final class UpcomingViewController: BaseViewController {
    override func addAttributes() {
        self.view.backgroundColor = Color.black
    }
}
