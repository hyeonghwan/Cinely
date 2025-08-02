//
//  RecentSearchResultCell.swift
//  Cinely
//
//  Created by hwan on 8/1/25.
//

import UIKit
import Design

final class RecentSearchResultCell: BaseCollectionViewCell, CellIdentifialble {
    private let searchLabel = UILabel()
    private let deleteButton = UIButton()
    
    override func addChild() {
        self.contentView.addSubview(searchLabel)
        self.contentView.addSubview(deleteButton)
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addAttributes() {
        searchLabel.font = Font.regular14
        searchLabel.textColor = Color.black
        searchLabel.text = "안녕하세요"
        searchLabel.textAlignment = .center
        
        deleteButton.setImage(Icons.xmark, for: .normal)
        deleteButton.tintColor = Color.black
        deleteButton.imageView?.contentMode = .scaleAspectFit
        
        self.backgroundColor = Color.white
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 16
    }
    
    override func addLayout() {
        deleteButton.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        NSLayoutConstraint.activate([
            searchLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
            searchLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8),
            searchLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 8),
            searchLabel.trailingAnchor.constraint(equalTo: self.deleteButton.leadingAnchor, constant: -6),
            
            deleteButton.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -8),
            deleteButton.centerYAnchor.constraint(equalTo: searchLabel.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: 15),
            deleteButton.heightAnchor.constraint(equalToConstant: 15)
        ])
    }
    
    func setText(_ string: String) {
        self.searchLabel.text = string
    }
}
