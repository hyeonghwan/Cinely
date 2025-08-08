//
//  UpCommingViewController.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import Design

final class UpCommingViewController: BaseViewController {
    private let label = UILabel()
    
    override func addAttributes() {
        setNavigationTint()
        setNavigationColor()
        setDefaultBackground()
    }
    
    override func addChild() {
        self.view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Font.thin17
        label.textColor = Color.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = """
...안녕하세요 UPCOMMING FEATURE 입니다....
"""
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            label.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
