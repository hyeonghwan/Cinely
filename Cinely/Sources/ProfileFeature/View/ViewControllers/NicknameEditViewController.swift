//
//  NicknameEditViewController.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import Design
import RxSwift
import RxRelay


final class NicknameEditViewController: BaseViewController {
    private let nicknameInputField = BottomLayerTextField()
    private let editButton         = EditButton(title: "편집")
    
    private let leftDissmissButton = UIButton()
    private let saveButton = UIButton()
    
    private weak var coordinator: NicknamePresentCoordinator?
    private var viewModel: ChangeNickNameViewModel!
    private var disposeBag = DisposeBag()
    
    static func create(
        coordinator: NicknamePresentCoordinator,
        viewModel: ChangeNickNameViewModel,
        userNickName: String
    ) -> NicknameEditViewController
    {
        let vc = NicknameEditViewController()
        vc.nicknameInputField.text = userNickName
        vc.coordinator = coordinator
        vc.viewModel = viewModel
        return vc
    }
    
    override func addAttributes() {
        setDefaultBackground()
        setNavigationTint()
        setNavigationBackButton()
        setNavigationColor()
        nicknameInputField.attributedPlaceholder = NSAttributedString(string: "편집 버튼을 눌러 닉네임을 설정해주세요", attributes: [.foregroundColor : Color.white.withAlphaComponent(0.6), .font: Font.regular14])
        nicknameInputField.isEnabled = false
        nicknameInputField.tintColor = Color.white
        nicknameInputField.textColor = Color.white
        self.title = "닉네임 편집"
        
        leftDissmissButton.tintColor = Color.green
        leftDissmissButton.setImage(Icons.xmark, for: .normal)
        let pointSize: CGFloat = 22
        let imageConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = imageConfig
        config.background.backgroundColor = .clear
        leftDissmissButton.configuration = config
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftDissmissButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: saveButton)
        
        saveButton.setTitle("저장", for: .normal)
        saveButton.setTitleColor(Color.green, for: .normal)
    }
    
    override func addChild() {
        self.view.addSubview(leftDissmissButton)
        self.view.addSubview(saveButton)
        self.view.addSubview(nicknameInputField)
        self.view.addSubview(editButton)
        nicknameInputField.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            nicknameInputField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nicknameInputField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            nicknameInputField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -44),
            nicknameInputField.heightAnchor.constraint(equalToConstant: 52),
            
            editButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            editButton.bottomAnchor.constraint(equalTo: nicknameInputField.bottomAnchor),
            editButton.heightAnchor.constraint(equalTo: nicknameInputField.heightAnchor),
            editButton.widthAnchor.constraint(equalToConstant: 80),
        ])
    }
    
    override func binding() {
        viewModel.nickNameRelayTrigger
            .skip(1)
            .map(\.0)
            .bind(to: nicknameInputField.rx.text)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .subscribe(with: self, onNext: { vc, value in
                vc.coordinator?.pushNicknameDetailEdit()
            })
            .disposed(by: disposeBag)
        
        leftDissmissButton.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                vc.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        saveButton.rx.tap
            .withLatestFrom(viewModel.nickNameRelayTrigger)
            .subscribe(with: self, onNext: { vc, state in
                vc.nicknameInputField.resignFirstResponder()
                let (nickname, inputState) = state
                if inputState == .valid {
                    vc.viewModel.changeNicknameTrigger.onNext(nickname)
                    vc.coordinator?.dismissPresented()
                } else {
                    vc.showToastMessage(
                        offsetY: UIScreen.main.bounds.height - 200,
                        status: inputState.toastState,
                        message: inputState.rawValue
                    )
                }
            })
            .disposed(by: disposeBag)
    }
}
