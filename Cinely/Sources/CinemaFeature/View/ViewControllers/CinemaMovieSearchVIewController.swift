//
//  CinemaMovieSearchVIewController.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design
import RxSwift
import HwanMacros

@Logging
final class CinemaMovieSearchVIewController: BaseViewController {
    
    static func create(with dependency: CinemaSearchViewModel) -> CinemaMovieSearchVIewController {
        let vc = CinemaMovieSearchVIewController()
        vc.searchViewModel = dependency
        return vc
    }
    
    private var searchViewModel: CinemaSearchViewModel!
    private let tableView = CinemaSearchTableView()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func addAttributes() {
        setDefaultBackground()
        searchBarSetting()
        tableView.estimatedRowHeight = 200
    }
    
    private func searchBarSetting() {
        searchController.searchBar.placeholder = "영화 제목을 검색해주세요"
        searchController.searchBar.searchTextField.font = Font.regular14
        self.navigationItem.title = "영화 검색"
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async { [weak self] in
            if let self, let text = self.searchController.searchBar.text, !text.isEmpty {
                return
            }
            self?.navigationItem.searchController?.searchBar.becomeFirstResponder()
        }
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
    
    private let pagingFinishInput = PublishSubject<Void>()
    private let favoriteButtonTapped = PublishSubject<(row: Int, flag: Bool)>()
    private var disposeBag = DisposeBag()
    
    override func binding() {
        let searchSumit = searchController
            .searchBar.rx.searchButtonClicked
             .withUnretained(self)
             .compactMap { vc, _ in vc.searchController.searchBar.text }
        
        let pagingRequest = tableView.rx.didScroll
            .throttle(.milliseconds(600), latest: true, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { vc, _ -> PagingValue in vc.getTableViewPagingValue() }
            .filter(\.isPagingPossible)
        
        let output = searchViewModel.transform(
            input: CinemaSearchViewModel.Input(
                submit: searchSumit,
                paging: pagingRequest.map(\.void),
                pagingFinish: pagingFinishInput.asObservable(),
                favoriteButtonTapped: favoriteButtonTapped.asObservable()
            )
        )
        
        tableView.rx.modelSelected(CinemaSearchViewModel.SearchItem.self)
            .subscribe(with: self, onNext: { vc, model in
                if case let .movie(movieModel) = model {
                    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                        return
                    }
                    let detailVC = CinemaDetailViewController.create(
                        with: .init(
                            vmDependency: CinemaDetailViewModel.Dependency.init(
                                appState: appDelegate.appState,
                                appStorage: appDelegate.storage,
                                movieImageProvider: DefaultMovieImageProvider(networkManager: appDelegate.networkManager),
                                movieState: CinemaDetailViewModel
                                    .MovieState(
                                        movieModel: movieModel
                                    )
                            ),
                            movieModel: movieModel)
                    )
                    vc.navigationController?.pushViewController(detailVC, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        searchResultBinding(output: output)
    }
    
    private func searchResultBinding(output: CinemaSearchViewModel.Output) {
        output.results
            .drive(tableView.rx.items) { tableView, row, model in
                switch model {
                case .empty:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaEmptyCell.id) as? CinemaEmptyCell else { fatalError() }
                    cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
                    cell.selectionStyle = .none
                    return cell
                    
                case let .movie(model):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaSearchCell.id) as? CinemaSearchCell else {
                        fatalError()
                    }
                    cell.set(with: model)
                    
                    cell.likeButton.rx.tap
                        .subscribe(with: cell, onNext: { [weak self] cell, _ in
                            let origin = cell.likeButton.isSelected
                            let (row, flag) = (row, !origin)
                            self?.favoriteButtonTapped.onNext((row, flag))
                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.selectionStyle = .none
                    return cell
                    
                case .refresh:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: RefreshCell.id) as? RefreshCell else {
                        fatalError()
                    }
                    output.isPagingLoading
                        .drive(onNext: { value in
                            if value {
                                cell.refreshIndicator.startAnimating()
                            } else {
                                cell.refreshIndicator.stopAnimating()
                            }
                        })
                        .disposed(by: cell.disposeBag)
                    return cell
                case .last:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: LastEmptyCell.id) as? LastEmptyCell else {
                        fatalError()
                    }
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.results
            .drive(with: self, onNext: { vc, _ in
                DispatchQueue.main.async {
                    vc.pagingFinishInput.onNext(())
                }
            })
            .disposed(by: disposeBag)
    }
}

typealias PagingValue = CinemaMovieSearchVIewController.PagingValue
extension CinemaMovieSearchVIewController {
    struct PagingValue {
        let contentOffsetY: CGFloat
        let contentHeight: CGFloat
        let boundsHeight: CGFloat
        var void: Void = ()
        var isPagingPossible: Bool {
            contentOffsetY > (contentHeight * 3) / 4
        }
    }
    
    func getTableViewPagingValue() -> PagingValue {
        PagingValue(
            contentOffsetY: self.tableView.contentOffset.y,
            contentHeight: self.tableView.contentSize.height,
            boundsHeight: self.tableView.bounds.height
        )
    }
}
