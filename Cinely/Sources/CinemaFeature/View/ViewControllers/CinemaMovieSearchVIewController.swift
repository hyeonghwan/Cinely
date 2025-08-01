//
//  CinemaMovieSearchVIewController.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

final class CinemaMovieSearchVIewController: BaseViewController {
    
    override func addChild() {
        setDefaultBackground()
        searchBarSetting()
    }
    
    private func searchBarSetting() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "영화 제목을 검색해주세요"
        searchController.searchBar.searchTextField.font = Font.regular14
        self.navigationItem.title = "영화 검색"
        self.navigationItem.searchController = searchController
    }
    
    override func addAttributes() {
        
    }
    
    override func addLayout() {
        
    }
    
    override func binding() {
        
    }
}
