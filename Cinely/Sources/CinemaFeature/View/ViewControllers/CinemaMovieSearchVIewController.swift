//
//  CinemaMovieSearchVIewController.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design
import RxSwift



final class CinemaMovieSearchVIewController: BaseViewController {
    
    static func create(
        with dependency: CinemaSearchViewModel,
        coordinator: CinemaMainCoordinator
    ) -> CinemaMovieSearchVIewController
    {
        let vc = CinemaMovieSearchVIewController()
        vc.searchViewModel = dependency
        vc.coordinator = coordinator
        return vc
    }
    
    private weak var coordinator: CinemaMainCoordinator?
    private var searchViewModel: CinemaSearchViewModel!
    private let tableView = CinemaSearchTableView(frame: .zero, style: .grouped)
    private var tableViewBottomConstraint: NSLayoutConstraint!
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func addAttributes() {
        setDefaultBackground()
        searchBarSetting()
        setNavigationBackButton()
        tableView.estimatedRowHeight = 200
        tableView.backgroundColor = .black
        tableView.separatorStyle = .none
    }
    
    private func searchBarSetting() {
        searchController.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(
            string: "영화 제목을 검색해주세요",
            attributes: [.foregroundColor : Color.white.withAlphaComponent(0.6)]
        )
        searchController.searchBar.searchTextField.font = Font.regular14
        self.navigationItem.title = "영화 검색"
        navigationItem.hidesSearchBarWhenScrolling = false
        self.navigationItem.searchController = searchController
        self.navigationItem.searchController?.searchBar.text = searchViewModel.word.isEmpty ? nil : searchViewModel.word
        self.navigationItem.searchController?.searchBar.searchTextField.textColor = .white
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let keyboardDownButton = UIBarButtonItem(
            image: Icons.keyboardDown,
            style: .plain,
            target: self,
            action: #selector(keyboardDown(_:))
        )
        keyboardDownButton.tintColor = Color.white
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [flexibleSpace, keyboardDownButton]
        searchController.searchBar.searchTextField.inputAccessoryView = toolbar
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
        tableViewBottomConstraint = tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        tableViewBottomConstraint.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    private let pagingFinishInput = PublishSubject<Void>()
    private let favoriteButtonTapped = PublishSubject<(row: Int, flag: Bool)>()
    private let viewDidLoad = PublishSubject<Void>()
    private let searchModeTrigger = PublishSubject<CinemaSearchViewModel.SearchMode>()
    private let recentHistoryTapped = PublishSubject<RecentSearchModel>()
    private let allDeleteActionTrigger = PublishSubject<Void>()
    private let recentSearchWordDeleteTrigger = PublishSubject<RecentSearchModel>()
    private var disposeBag = DisposeBag()
    
    private func keyboardWillAppear(notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        let keyboardHeight = keyboardFrame.height
        let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
        tableViewBottomConstraint.constant = -(keyboardHeight - tabBarHeight)
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardDown(_ sender: Any) {
        searchController.searchBar.searchTextField.resignFirstResponder()
    }
    
    private func keyboardWillDisappear(notification: Notification) {
        tableViewBottomConstraint.constant = 0
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.3
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func binding() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .do(onNext: { [weak self] in
                self?.keyboardWillAppear(notification: $0)
                self?.tableView.setContentOffset(.zero, animated: false)
            })
            .map { _ in CinemaSearchViewModel.SearchMode.suggestion }
            .bind(to: searchModeTrigger)
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .subscribe(with: self, onNext: { vc, notification in
                vc.tableView.setContentOffset(.zero, animated: false)
                vc.keyboardWillDisappear(notification: notification)
            })
            .disposed(by: disposeBag)
            
        
        self.tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // MARK: Input
        let searchSubmit = Observable.merge(
            searchController.searchBar.rx.searchButtonClicked
                .withUnretained(self)
                .do(onNext: { vc, _ in vc.searchModeTrigger.onNext(.searchResult) })
                .compactMap { vc, _ in
                    vc.searchController.searchBar.text
                }
                .filter { !$0.isEmpty },
            
            recentHistoryTapped
                .do(onNext: { [weak self] recentSearchModel in
                    self?.searchModeTrigger.onNext(.searchResult)
                    self?.searchController.searchBar.text = recentSearchModel.word
                    self?.searchController.searchBar.resignFirstResponder()
                })
                .map(\.word)
                .filter { !$0.isEmpty }
        )
        
        let pagingRequest = tableView.rx.didScroll
            .throttle(.milliseconds(600), latest: true, scheduler: MainScheduler.instance)
            .withUnretained(self)
            .map { vc, _ -> PagingValue in vc.getTableViewPagingValue() }
            .filter(\.isPagingPossible)
        
        let output = searchViewModel.transform(
            input: CinemaSearchViewModel.Input(
                submit: searchSubmit,
                paging: pagingRequest.map(\.void),
                pagingFinish: pagingFinishInput.asObservable(),
                favoriteButtonTapped: favoriteButtonTapped.asObservable(),
                viewDidLoad: viewDidLoad.asObservable(),
                searchModeTrigger: searchModeTrigger.asObservable(),
                allDeleteActionTrigger: allDeleteActionTrigger.asObservable(),
                recentSearchWordDeleteTrigger: recentSearchWordDeleteTrigger.asObservable()
            )
        )
        
        tableView.rx.modelSelected(CinemaSearchViewModel.SearchItem.self)
            .subscribe(with: self, onNext: { vc, model in
                if case let .movie(movieModel) = model {
                    vc.coordinator?.moveToDetail(movieModel)
                } else if case let .suggestion(word) = model {
                    vc.recentHistoryTapped.onNext(word)
                }
            })
            .disposed(by: disposeBag)
        
        output.alertTrigger
            .drive(errorDefaultOKAlert)
            .disposed(by: disposeBag)
        
        searchResultBinding(output: output)
        viewDidLoad.onNext(())
    }
    
    private func searchResultBinding(output: CinemaSearchViewModel.Output) {
        output.outputData
            .drive(tableView.rx.items) { tableView, row, model in
                switch model {
                case let .suggestion(recentWord):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchCell.id) as? RecentSearchCell else { fatalError() }
                    
                    cell.set(word: recentWord.word)
                    
                    cell.deleteButton.rx.tap
                        .subscribe(with: self, onNext: { vc, _ in
                            vc.recentSearchWordDeleteTrigger.onNext(recentWord)
                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.selectionStyle = .none
                    
                    return cell
                    
                case .emptySearchResult:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaEmptyCell.id) as? CinemaEmptyCell else { fatalError() }
                    cell.separatorInset = UIEdgeInsets(top: 0, left: UIScreen.main.bounds.width, bottom: 0, right: 0)
                    cell.selectionStyle = .none
                    cell.backgroundColor = .black
                    return cell
                    
                case .emptySearchHistory:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: RecentSearchEmptyTableViewCell.id) as? RecentSearchEmptyTableViewCell else { return UITableViewCell() }
                    cell.selectionStyle = .none
                    cell.backgroundColor = .black
                    return cell
                    
                case let .movie(model):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: CinemaSearchCell.id) as? CinemaSearchCell else {
                        fatalError()
                    }
                    cell.set(with: model)
                    cell.backgroundColor = .black
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
                    cell.selectionStyle = .none
                    cell.backgroundColor = .black
                    return cell
                    
                case .last:
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: LastEmptyCell.id) as? LastEmptyCell else {
                        fatalError()
                    }
                    cell.backgroundColor = .black
                    cell.selectionStyle = .none
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        output.outputData
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

extension CinemaMovieSearchVIewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch searchViewModel.currentMode.value {
        case .suggestion:
            let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SuggestionHeaderView.id) as! SuggestionHeaderView
            
            headerView.baseView.actionButton.rx.tap
                .withUnretained(self)
                .map { vc, _ -> (AlertMessage, () -> Void) in
                    (
                        .isAllDelete,
                        { vc.allDeleteActionTrigger.onNext(()) }
                    )
                }
                .bind(to: self.searchViewAllDeleteAlert)
                .disposed(by: headerView.disposeBag)
            
            return headerView
        case .searchResult:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch searchViewModel.currentMode.value {
        case .suggestion:
            return 50
        case .searchResult:
            return 0
        }
    }
}

// MARK: Alert Binder
extension CinemaMovieSearchVIewController {
    var searchViewAllDeleteAlert: Binder<(alertMessage: AlertMessage, delete: (() -> Void))> {
        Binder<(alertMessage: AlertMessage, delete: (() -> Void))>(self) { vc, type in
            vc.showDeleteAlert(
                title: type.alertMessage.title,
                message: type.alertMessage.message,
                { },
                type.delete
            )
        }
    }
}
