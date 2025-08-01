//
//  RecentSearchHeader.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

final class RecentSearchHeader: BaseReusableView, CellIdentifialble {
    private let sectionTitleLabel = UILabel()
    private var deleteButton = UIButton()

    override func addChild() {
        self.addSubview(sectionTitleLabel)
        self.addSubview(deleteButton)
        sectionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addAttributes() {
        sectionTitleLabel.font = Font.bold24
        sectionTitleLabel.textColor = Color.white
        deleteButton.setAttributedTitle(NSAttributedString(string: "전체 삭제", attributes: [.foregroundColor : Color.green]), for: .normal)
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            sectionTitleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            
            deleteButton.centerYAnchor.constraint(equalTo: sectionTitleLabel.centerYAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    func setTitle(_ string: String) {
        sectionTitleLabel.text = string
    }
    
    func setDeleteButtonHidden(_ bool: Bool) {
        deleteButton.isHidden = bool
    }
}
