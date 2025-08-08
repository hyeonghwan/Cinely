//
//  AppDependency.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import Foundation

struct AppDependency {
    let appState: AppState
    let appStorage: PersistentStorage
    let networkManager: NetworkManager
    let nwState: NWState
}

final class AppDependencyFactory {
    static func make() -> AppDependency {
        let networkManager: NetworkManager = DefaultNetworkManager()
        let networkState = NWState()
        
        let storage: PersistentStorage = DefaultPersistentStorage()
        let appState = DefaultAppState(
            dependency: DefaultAppState.Dependency(
                appProvider: DefaultAppProvider(
                    networkManager: networkManager
                ),
                appStorage: storage
            )
        )
        
        appState.appBootStrap()
        
        return AppDependency(
            appState: appState,
            appStorage: storage,
            networkManager: networkManager,
            nwState: networkState
        )
    }
}
