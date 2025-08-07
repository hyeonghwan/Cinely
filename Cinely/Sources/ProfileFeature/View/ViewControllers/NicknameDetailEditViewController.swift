//
//  NicknameDetailEditViewController.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import Design
import RxSwift

final class NicknameDetailEditViewController: BaseViewController {
    private let nicknameInputField = BottomLayerTextField()
    private let informationLabel   = UILabel()
    weak var coordinator: NicknamePresentCoordinator?
    private var viewModel: ChangeNickNameViewModel!
    
    static func create(coordinator: NicknamePresentCoordinator, viewModel: ChangeNickNameViewModel) -> NicknameDetailEditViewController {
        let vc = NicknameDetailEditViewController()
        vc.coordinator = coordinator
        vc.viewModel = viewModel
        return vc
    }
    
    override func addAttributes() {
        setDefaultBackground()
        self.navigationItem.title = "닉네임 편집"
        nicknameInputField.attributedPlaceholder = NSAttributedString(string: "닉네임을 입력해주세요!", attributes: [.foregroundColor : Color.white.withAlphaComponent(0.6), .font: Font.regular14])
        informationLabel.text = "닉네임에 숫자는 포함할 수 없어요"
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
    
    private let statusTrigger = PublishSubject<(String, InputStatus)>()
    private var disposeBag = DisposeBag()
    
    override func binding() {
        nicknameInputField.becomeFirstResponder()
        
        statusTrigger
            .subscribe(with: self, onNext: { vc, status in
                vc.informationLabel.text = status.1.rawValue
                vc.informationLabel.textColor = status.1.color
                vc.nicknameInputField.btBorderColor = status.1.color.cgColor
                vc.viewModel.nickNameRelayTrigger.accept(status)
            })
            .disposed(by: disposeBag)
        
        nicknameInputField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(with: self, onNext: { vc, value in
                vc.view.endEditing(true)
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        nicknameInputField.rx.text
            .compactMap { $0 }
            .map { InputStatus.validate($0) }
            .bind(to: statusTrigger)
            .disposed(by: disposeBag)
    }
}

