//
//  NicknameSettingViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class NicknameSettingViewController: BaseViewController {
    
    private let nicknameInputField = BottomLayerTextField()
    private let completionButton   = GreenLayerButton(title: "완료")
    private let editButton         = EditButton(title: "편집")
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        
        nicknameInputField.placeholder = "편집 버튼을 눌러 닉네임을 설정해주세요"
        nicknameInputField.isEnabled = false
    }
    
    override func addChild() {
        self.view.addSubview(nicknameInputField)
        self.view.addSubview(completionButton)
        self.view.addSubview(editButton)
        
        nicknameInputField.translatesAutoresizingMaskIntoConstraints = false
        completionButton.translatesAutoresizingMaskIntoConstraints   = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            nicknameInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nicknameInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nicknameInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),
            nicknameInputField.heightAnchor.constraint(equalToConstant: 52),
            
            editButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            editButton.bottomAnchor.constraint(equalTo: nicknameInputField.bottomAnchor),
            editButton.heightAnchor.constraint(equalTo: nicknameInputField.heightAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 80),
            
            completionButton.topAnchor.constraint(equalTo: nicknameInputField.bottomAnchor, constant: 44),
            completionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            completionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            completionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func binding() {
        editButton.addAction(
            UIAction { [weak self] _ in
                let detailVC = NicknameDetailViewController()
                detailVC.title = self?.title
                self?.navigationController?.pushViewController(detailVC, animated: true)
            },
            for: .touchUpInside
        )
    }
}
