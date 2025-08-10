//
//  OnboardingViewModel.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import RxSwift
import RxCocoa

final class OnboardingFeatureViewModel {
    struct Input { }
    struct Output { }
    func transform(input: Input) -> Output { return Output() }
    init(appState: AppState) {
        self.appState = appState
        defer {
            singUpTrigger
                .subscribe(with: self, onNext: { vm, value in
                    vm.appState.signUpBinder.onNext(
                        User(nickname: value, likeCount: 0, signUpDate: Date.now.toISO8601String())
                    )
                })
                .disposed(by: disposeBag)
        }
    }
    
    private var appState: AppState
    private var disposeBag = DisposeBag()
    private(set) var nickNameRelayTrigger = BehaviorRelay<(String, InputStatus)>(value: ("", .none))
    private(set) var singUpTrigger = PublishSubject<String>()
}
