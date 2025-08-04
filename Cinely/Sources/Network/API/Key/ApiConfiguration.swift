//
//  APIKEY.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import Foundation


enum ApiConfiguration {
    static let MOVIE_DB_URL = Bundle.main.infoDictionary?["MOVIE_DB_URL"] as! String
    static let API_TOKEN = Bundle.main.infoDictionary?["TOKEN"] as! String
}
