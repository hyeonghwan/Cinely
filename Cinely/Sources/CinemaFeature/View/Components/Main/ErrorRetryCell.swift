//
//  ErrorRetryCell.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import Design
import RxSwift

final class ErrorRetryCell: BaseCollectionViewCell, CellIdentifialble {
    private(set) var titleLabel = UILabel()
    private(set) var errorContentLabel = UILabel()
    private(set) var retryButton = LoadingButton(title: "재시도")
    var disposeBag = DisposeBag()
    
    override func addChild() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(errorContentLabel)
        contentView.addSubview(retryButton)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        errorContentLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func addAttributes() {
        self.contentView.backgroundColor = Color.white.withAlphaComponent(0.1)
        self.contentView.layer.cornerRadius = 16
        
        titleLabel.font = Font.bold17
        titleLabel.textAlignment = .center
        titleLabel.textColor = Color.white
        titleLabel.numberOfLines = 2
        
        titleLabel.text = "Please Retry"
        errorContentLabel.text = "We Will attempt to recover by breaking connection but failed so please try again"
        
        errorContentLabel.font = Font.light14
        errorContentLabel.textAlignment = .center
        errorContentLabel.textColor = Color.white.withAlphaComponent(0.8)
        errorContentLabel.numberOfLines = 3
    }
    
    func settingErrorMessage(title: String, errorContent: String) {
        self.titleLabel.text = title
        self.errorContentLabel.text = errorContent
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            errorContentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            errorContentLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            errorContentLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            
            retryButton.topAnchor.constraint(equalTo: errorContentLabel.bottomAnchor, constant: 24),
            retryButton.centerXAnchor.constraint(equalTo: titleLabel.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 200),
            retryButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -12)
        ])
    }
}


