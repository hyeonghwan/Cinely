//
//  Storage.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation
import RxSwift
import HwanMacros

protocol PersistentStorage {
    func dummyLoad() -> [RecentSearchModel]
}

final class DefaultAppStorage: PersistentStorage {
    init() { }
    
    func dummyLoad() -> [RecentSearchModel] {
        
        return [
        RecentSearchModel(word: "마블", lastSearchDate: "2025.08.02"),
        RecentSearchModel(word: "스파이더맨", lastSearchDate: "2025.08.01"),
        RecentSearchModel(word: "배트맨!", lastSearchDate: "2025.07.31"),
        RecentSearchModel(word: "서울#의 봄", lastSearchDate: "2025.07.29"),
        RecentSearchModel(word: "범죄$도시4", lastSearchDate: "2025.07.25"),
        RecentSearchModel(word: "인사이드 $!5아웃 2", lastSearchDate: "2025.07.22"),
        RecentSearchModel(word: "로맨스 #영화# 추천", lastSearchDate: "2025.07.15"),
        RecentSearchModel(word: "듄 파ㅇㅁㄹ트2", lastSearchDate: "2025.06.30"),
        RecentSearchModel(word: "오펜하이머", lastSearchDate: "2025.06.11"),
        RecentSearchModel(word: "핳ㅎ핳ㅎ", lastSearchDate: "2025.05.05")
    ]
    }
}

enum Storage {
    @KeyValueStore(key: .userName, defaultValue: "Guest_HWAN")
    static var userName: String
    
    @KeyValueStore(key: .userSignUpDate, defaultValue: Date.now)
    static var userSignUpDate: Date
    
    @KeyValueStore(key: .userSignUpDate, defaultValue: false)
    static var didFinishOnboarding: Bool
    
    @CodableStore(key: .favoriteMovie, defaultValue: [])
    static var favoriteMovie: [TodayMovieModel]
    
    @CodableStore(key: .recentSearchWords, defaultValue: [])
    static var recentSearchWords: [RecentSearchModel]
    
    fileprivate enum StorageKey: String {
        case userName
        case userSignUpDate
        case favoriteMovie
        case recentSearchWords
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
                    LoggingMacroHelper.generate(category: String(describing: Self.self))
                        .log(level: .info, "Error decoding \(T.self): \(error)")
                    return defaultValue
                }
            }
            set {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    UserDefaults.standard.set(data, forKey: key.rawValue)
                } catch {
                    LoggingMacroHelper.generate(category: String(describing: Self.self))
                        .log(level: .info, "Error decoding \(T.self): \(error)")
                }
            }
        }
    }
}

