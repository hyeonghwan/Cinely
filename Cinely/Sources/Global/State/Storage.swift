//
//  Storage.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxSwift
import RxRelay

enum Storage {
    @KeyValueStore(key: .userName, defaultValue: "Guest_HWAN")
    static var userName: String
    
    @KeyValueStore(key: .userSignUpDate, defaultValue: Date.now.toISO8601String())
    static var userSignUpDate: String
    
    @KeyValueStore(key: .userLikeCount, defaultValue: 0)
    static var userLikeCount: Int
    
    @KeyValueStore(key: .didFinishOnboarding, defaultValue: false)
    static var didFinishOnboarding: Bool
    
    @CodableStore(key: .favoriteMovie, defaultValue: [])
    static var favoriteMovie: [TodayMovieModel]
    
    @CodableStore(key: .recentSearchModels, defaultValue: [])
    static var recentSearchModels: [RecentSearchModel]
    
    fileprivate enum StorageKey: String {
        case userName
        case userSignUpDate
        case userLikeCount
        case favoriteMovie
        case recentSearchModels
        case didFinishOnboarding
    }
    
    @propertyWrapper
    struct KeyValueStore<T> {
        private let key: StorageKey
        private let defaultValue: T

        fileprivate init(key: StorageKey, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }

        var wrappedValue: T {
            get {
                return UserDefaults.standard.object(forKey: key.rawValue) as? T ?? defaultValue
            }
            set {
                UserDefaults.standard.set(newValue, forKey: key.rawValue)
            }
        }
    }
    
    @propertyWrapper
    struct CodableStore<T: Codable> {
        private let key: StorageKey
        private let defaultValue: T
        
        fileprivate init(key: StorageKey, defaultValue: T) {
            self.key = key
            self.defaultValue = defaultValue
        }
        
        var wrappedValue: T {
            get {
                guard let data = UserDefaults.standard.data(forKey: key.rawValue) else {
                    return defaultValue
                }
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    return model
                } catch {
                    // LoggingMacroHelper.generate(category: String(describing: Self.self))
                       //  .log(level: .info, "Error decoding \(T.self): \(error)")
                    return defaultValue
                }
            }
            set {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: key.rawValue)
                } catch {
                    // LoggingMacroHelper.generate(category: String(describing: Self.self))
                       //  .log(level: .info, "Error decoding \(T.self): \(error)")
                }
            }
        }
    }
}

