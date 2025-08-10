//
//  ResultEmptyCell.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

final class RecentSearchEmptyCell: BaseCollectionViewCell, CellIdentifialble {
    private let noRecentLabel = UILabel()
    
    override func addChild() {
        self.addSubview(noRecentLabel)
        noRecentLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addAttributes() {
        noRecentLabel.text = "최근 검색어 내역이 없습니다."
        noRecentLabel.font = Font.thin14
        noRecentLabel.textAlignment = .center
        noRecentLabel.textColor = Color.mediumGray.withAlphaComponent(0.6)
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            noRecentLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            noRecentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            noRecentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            noRecentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}

final class RecentSearchEmptyTableViewCell: BaseTableViewCell, CellIdentifialble {
    private let noRecentLabel = UILabel()
    
    override func addChild() {
        self.addSubview(noRecentLabel)
        noRecentLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addAttributes() {
        noRecentLabel.text = "최근 검색어 내역이 없습니다."
        noRecentLabel.font = Font.thin14
        noRecentLabel.textAlignment = .center
        noRecentLabel.textColor = Color.mediumGray.withAlphaComponent(0.6)
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            noRecentLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24),
            noRecentLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            noRecentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            noRecentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}


