//
//  ProfileSettingViewController.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design


final class ProfileSettingViewController: BaseViewController {
    private let containerView = UIView()
    private let profileView = ProfileView()
    
    private let tableView = UITableView()
    private let list = ["자주 묻는 질문", "1:1 문의" , "알림 설정", "탈퇴 하기"]

    var appState: AppState!
    var coordinator: ProfileSettingCoordinator!
    
    static func create(appState: AppState, coordinator: ProfileSettingCoordinator) -> ProfileSettingViewController {
        let vc = ProfileSettingViewController()
        vc.appState = appState
        vc.coordinator = coordinator
        return vc
    }
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        addContainerSetting()
        self.navigationItem.title = "설정"
        tableView.register(TableCell.self, forCellReuseIdentifier: TableCell.id)
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
    
    override func binding() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ProfileSettingViewController: UITableViewDelegate, UITableViewDataSource {
    private class TableCell: BaseTableViewCell, CellIdentifialble {
        private let titleLabel = UILabel()
        
        override func addAttributes() {
            titleLabel.font = Font.light17
            titleLabel.textColor = Color.white
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
    
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { list.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.id, for: indexPath) as! TableCell
        cell.set(title: list[indexPath.row])
        return cell
    }
}
