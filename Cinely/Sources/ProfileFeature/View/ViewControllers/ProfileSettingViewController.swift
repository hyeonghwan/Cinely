//
//  ProfileSettingViewController.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design
import RxSwift
import RxCocoa

final class ProfileSettingViewController: BaseViewController {

    static func create(appState: AppState, coordinator: ProfileSettingCoordinator) -> ProfileSettingViewController {
        let vc = ProfileSettingViewController()
        vc.coordinator = coordinator
        vc.appState = appState
        return vc
    }
    
    private weak var coordinator: ProfileSettingCoordinator?
    private var appState: AppState!
    private var disposeBag = DisposeBag()
    private var userRelay = BehaviorRelay<User?>(value: nil)
    
    private let containerView = UIView()
    private let profileView = ProfileView()
    
    private let tableView = UITableView()
    private let list = ["자주 묻는 질문", "1:1 문의" , "알림 설정", "탈퇴하기"]
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        setNavigationColor()
        addContainerSetting()
        
        self.navigationItem.title = "설정"
        tableView.register(TableCell.self, forCellReuseIdentifier: TableCell.id)
        tableView.backgroundColor = .black
        profileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profileTapped(_:))))
    }
    
    @objc
    private func profileTapped(_ sender: UITapGestureRecognizer) {
        if let coordinator = coordinator as? NicknamePresentCoordinator,
            let user = userRelay.value
        {
            coordinator.presentNicknameSetting(userNickName: user.nickname)
        }
    }
    
    private func addContainerSetting() {
        self.containerView.addSubview(profileView)
        containerView.backgroundColor = .clear
        profileView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profileView.topAnchor.constraint(equalTo: containerView.topAnchor),
            profileView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            profileView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            profileView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    override func addChild() {
        tableView.tableHeaderView = containerView
        containerView.bounds = CGRect(origin: .zero, size: CGSize(width: UIScreen.main.bounds.width, height: 135))
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private let modelSelected = BehaviorRelay<String>(value: "")
    
    override func binding() {
        tableView.delegate = self
        tableView.dataSource = self
        
        modelSelected
            .skip(1)
            .filter { $0 == "탈퇴하기" }
            .bind(to: alertBinder)
            .disposed(by: disposeBag)
        
        userRelay
            .compactMap { $0 }
            .bind(to: profileView.binder)
            .disposed(by: disposeBag)
        
        appState.userState
            .bind(to: userRelay)
            .disposed(by: disposeBag)
    }
}

extension ProfileSettingViewController {
    var alertBinder: Binder<String> {
        Binder<String>(self) { vc, string in
            vc.showSignOutAlert(
                title: "탈퇴하기",
                message: "탈퇴를 하면 데이터가 모두 초기화됩니다.\n탈퇴 하시겠습니까?",
                {
                    vc.appState.signOutBinder.onNext(())
                    vc.coordinator?.signOut()
                },
                { print("cancel") }
            )
        }
    }
}

extension ProfileSettingViewController: UITableViewDataSource, UITableViewDelegate {
    private class TableCell: BaseTableViewCell, CellIdentifialble {
        private let titleLabel = UILabel()
        
        override func addAttributes() {
            titleLabel.font = Font.light17
            titleLabel.textColor = Color.white
            self.backgroundColor = .black
            self.contentView.backgroundColor = .black
        }
        
        override func addChild() {
            self.contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
        }
        
        override func addLayout() {
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
                titleLabel.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
            ])
        }
        
        func set(title: String) {
            titleLabel.text = title
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        modelSelected.accept(list[indexPath.row])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { list.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.id, for: indexPath) as! TableCell
        cell.set(title: list[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
}
