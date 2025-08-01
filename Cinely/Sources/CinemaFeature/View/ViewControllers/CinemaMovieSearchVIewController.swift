//
//  CinemaMovieSearchVIewController.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

final class SearchViewModel {
    var models: [TodayMovieModel] = TodayMovieModel.dummyList
}

final class CinemaMovieSearchVIewController: BaseViewController {
    private let tableView = CinemaSearchTableView()
    private let viewModel = SearchViewModel()
    
    override func addAttributes() {
        setDefaultBackground()
        searchBarSetting()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 200
    }
    
    private func searchBarSetting() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "영화 제목을 검색해주세요"
        searchController.searchBar.searchTextField.font = Font.regular14
        self.navigationItem.title = "영화 검색"
        self.navigationItem.searchController = searchController
    }
    
    override func addChild() {
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func binding() {
    }
}

extension CinemaMovieSearchVIewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.models.isEmpty ? 1 : viewModel.models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.models.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaEmptyCell.id) as? CinemaEmptyCell else {
                fatalError()
            }
            cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
            cell.selectionStyle = .none
            return cell
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaSearchCell.id) as? CinemaSearchCell else {
            fatalError()
        }
        cell.set(with: viewModel.models[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
