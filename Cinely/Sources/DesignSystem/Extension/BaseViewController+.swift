//
//  BaseViewController+.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import RxSwift

extension BaseViewController {
    var errorDefaultOKAlert: Binder<ErrorMessage> {
        Binder<ErrorMessage>(self) { vc, errMessage in
            vc.showDefaultAlert(
                title: "\(errMessage.title)",
                message: "\(errMessage.message)",
                {  }
            )
        }
    }
    var errorRetryAlert: Binder<ErrorMessage> {
        Binder<ErrorMessage>(self) { vc, errMessage in
            vc.showRetryAlert(
                title: errMessage.title,
                message: errMessage.message,
                errMessage.retry,
                { }
            )
        }
    }
}

extension BaseViewController {
    func setDefaultBackground() {
        self.view.backgroundColor = Color.black
    }
    
    func setNavigationTint() {
        self.navigationController?.navigationBar.tintColor = Color.green
    }
    
    func setNavigationBackButton() {
        navigationItem.backButtonTitle = ""
    }
    
    func setNavigationColor() {
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = [.foregroundColor: Color.white]
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.black
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationController?.navigationBar.tintColor = Color.green
        navigationItem.backButtonDisplayMode = .minimal
    }
    
    @objc
    func keyboardDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    public func showSignOutAlert(title: String, message: String, _ ok: @escaping () -> Void, _ cancel: @escaping () -> Void) {
        let ok = AlertAction(text: "확인", color: .black, action: { ok() })
        let cancel = AlertAction(text: "취소", color: .red, action: { cancel() })
        self.showAlert(
            title: title,
            message: message,
            action: ok, cancel
        )
    }
    
    public func showDefaultAlert(title: String, message: String, color: UIColor = .black, _ ok: @escaping () -> Void) {
        let ok = AlertAction(text: "확인", color: .black, action: { ok() })
        self.showAlert(
            title: title,
            message: message,
            action: ok
        )
    }
    
    public func showRetryAlert(title: String, message: String, _ retry: @escaping () -> Void, _ cancel: @escaping () -> Void) {
        let ok     = AlertAction(text: "재시도", color: .red, action: { retry() })
        let cancel = AlertAction(text: "확인", color: .black, action: { cancel() })
        self.showAlert(
            title: title,
            message: message,
            action: ok, cancel
        )
    }
}
