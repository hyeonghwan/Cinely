//
//  LastCell.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import UIKit
import Design
import RxSwift

final class RefreshCell: BaseTableViewCell, CellIdentifialble {
    
    private(set) var refreshIndicator = UIActivityIndicatorView()
    var disposeBag = DisposeBag()
    
    override func addAttributes() {
        refreshIndicator.color = .green
        refreshIndicator.style = .large
        refreshIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func addChild() {
        self.addSubview(refreshIndicator)
    }
    
    override func addLayout() {
        NSLayoutConstraint.activate([
            refreshIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            refreshIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            refreshIndicator.topAnchor.constraint(equalTo: self.topAnchor),
            refreshIndicator.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
