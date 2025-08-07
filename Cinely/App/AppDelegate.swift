//
//  AppDelegate.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import RxSwift

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    let networkManager: NetworkManager = DefaultNetworkManager.shared
    
    let storage: PersistentStorage = DefaultAppStorage()
    lazy var movieSearchProvider: MovieSearchProvider = DefaultMovieSearchProvider(networkManager: networkManager)
    lazy var appState = DefaultAppState(
        dependency: .init(
            appProvider: DefaultAppProvider(
                networkManager: networkManager
            ),
            appStorage: storage
        )
    )
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        sleep(2)
        return true
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
