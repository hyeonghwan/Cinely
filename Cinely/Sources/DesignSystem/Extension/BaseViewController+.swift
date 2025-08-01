//
//  BaseViewController+.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

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
    
    @objc
    func keyboardDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
}
