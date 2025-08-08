//
//  LastCell.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import UIKit
import Design

final class LastEmptyCell: BaseTableViewCell, CellIdentifialble {
    private let label = UILabel()
    
    override func addAttributes() {
        label.font = Font.thin17
        label.textColor = Color.mediumGray.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.text = "더 이상 결과가 없습니다."
    }
    
    override func addChild() {
        self.contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let heightAnchor = label.heightAnchor.constraint(equalToConstant: 50)
        heightAnchor.priority = .defaultHigh
        
        heightAnchor.isActive = true
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
