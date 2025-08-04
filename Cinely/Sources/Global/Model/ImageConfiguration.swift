//
//  ImageConfiguration.swift
//  Cinely
//
//  Created by hwan on 8/3/25.
//

import Foundation


struct ImageConfiguration: Decodable {
    let baseURL: String
    let secureBaseURL: String
    let backdropSizes: [String]
    let logoSizes: [String]
    let posterSizes: [String]
    let profileSizes: [String]
    let stillSizes: [String]
}

extension ImageConfiguration {
    func getBackDropSizeW780(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w780" + filePath
    }
    
    func getBackDropSizeW300(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w300" + filePath
    }
    
    func getBackDropSizeW1280(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w300" + filePath
    }
    
    func getBackDropSizeOrigin(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "original" + filePath
    }
    
    func getPosterPathSizeW342(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w342" + filePath
    }
    
    func getPosterPathSizeW500(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w500" + filePath
    }
    func getPosterPathSizeOriginal(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "original" + filePath
    }
    
    func getProfilePathSizew45(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w45" + filePath
    }
    
    func getProfilePathSizew185(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "w185" + filePath
    }
    
    func getProfilePathSizeOriginal(filePath: String) -> String {
        if filePath.isEmpty { return "" }
        return self.secureBaseURL + "original" + filePath
    }
}


extension ImageConfigurationDTO {
    func toConfig() -> ImageConfiguration {
        ImageConfiguration(
            baseURL: self.baseURL ?? "http://image.tmdb.org/t/p/",
            secureBaseURL: self.secureBaseURL ?? "https://image.tmdb.org/t/p/",
            backdropSizes: self.backdropSizes ?? ["w300", "w780", "w1280", "original"],
            logoSizes: self.logoSizes ?? ["w45", "w92", "w154", "w185", "w300", "w500", "original"],
            posterSizes: self.posterSizes ?? ["w92", "w154", "w185", "w342", "w500", "w780", "original"],
            profileSizes: self.profileSizes ?? ["w45", "w185", "h632", "original"],
            stillSizes: self.stillSizes ?? ["w92", "w185", "w300", "original"]
        )
    }
}
