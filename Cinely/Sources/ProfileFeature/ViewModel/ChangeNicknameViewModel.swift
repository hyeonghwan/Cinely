//
//  ChangeNicknameViewModel.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import Foundation
import RxSwift
import RxRelay

final class ChangeNickNameViewModel {
    init(appState: AppState) {
        self.appState = appState
        defer {
            changeNicknameTrigger
                .subscribe(with: self, onNext: { vm, value in
                    vm.appState.changeNickNameBinder.onNext(value)
                })
                .disposed(by: disposeBag)
        }
    }
    
    private var appState: AppState
    private var disposeBag = DisposeBag()
    private(set) var nickNameRelayTrigger = BehaviorRelay<(String, InputStatus)>(value: ("", .none))
    private(set) var changeNicknameTrigger = PublishSubject<String>()
}
