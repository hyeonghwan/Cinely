//
//  NicknameDetailViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class NicknameDetailViewController: BaseViewController {
    
    private let nicknameInputField = BottomLayerTextField()
    private let informationLabel   = UILabel()
    
    
    override func addAttributes() {
        setDefaultBackground()
        nicknameInputField.placeholder = "닉네임을 입력해주세요!"
        informationLabel.text = "닉네임에 숫자는 포함할 수 없어요"
        informationLabel.textColor = .red
        informationLabel.font = Font.semiBold14
    }
    
    override func addChild() {
        self.view.addSubview(nicknameInputField)
        self.view.addSubview(informationLabel)
        nicknameInputField.translatesAutoresizingMaskIntoConstraints = false
        informationLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            nicknameInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nicknameInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nicknameInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            nicknameInputField.heightAnchor.constraint(equalToConstant: 52),
            
            informationLabel.topAnchor.constraint(equalTo: nicknameInputField.bottomAnchor, constant: 16),
            informationLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24)
        ])
    }
    
    override func binding() {
        let tap = UITapGestureRecognizer()
        self.view.addGestureRecognizer(tap)
        tap.addTarget(self, action: #selector(keyboardDismiss(_:)))
    }
}
