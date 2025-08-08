//
//  LoadingButton.swift
//  Cinely
//
//  Created by hwan on 8/6/25.
//

import UIKit
import HwanKit

final class LoadingButton: BaseButton {
    private let loading = UIActivityIndicatorView(style: .medium)
    private var attrTitle: NSAttributedString?
    private var emptyTitle: NSAttributedString = NSAttributedString(string: "")
    var isLoading: Bool = false {
        didSet {
            updateView()
        }
    }
    
    convenience init(
        title: String = "재시도",
        font: UIFont = Font.light17,
        color: UIColor = Color.redAlpha08,
        loadingStyle: UIActivityIndicatorView.Style = .medium,
        loadingColor: UIColor = Color.green
    ) {
        self.init(frame: .zero)
        attrTitle = NSAttributedString(string: "\(title)", attributes: [.font: font, .foregroundColor: color ])
        self.setAttributedTitle(attrTitle, for: .normal)
        loading.style = loadingStyle
        loading.color = loadingColor
        addLayout()
    }
    
    override func addAttributes() {
        loading.hidesWhenStopped = true
        loading.isUserInteractionEnabled = false
    }
    
    func updateView() {
        if isLoading {
            self.setAttributedTitle(emptyTitle, for: .normal)
            loading.startAnimating()
        } else {
            self.setAttributedTitle(attrTitle, for: .normal)
            loading.stopAnimating()
        }
    }
    
    private func addLayout() {
        self.addSubview(self.loading)
        self.loading.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.loading.centerXAnchor.constraint(equalTo: centerXAnchor),
            self.loading.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
