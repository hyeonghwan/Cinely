//
//  Gredient.swift
//  Cinely
//
//  Created by hwan on 8/9/25.
//

import UIKit
import HwanKit

final class CapsulePageCounterView: BaseView {
    private let pageLabel = UILabel()
    private let gradientLayer = CAGradientLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
    
    override func addAttributes() {
        self.backgroundColor = Color.white.withAlphaComponent(0.1)
        pageLabel.textColor = .white
        pageLabel.font = Font.light12
        pageLabel.textAlignment = .center
        pageLabel.text = "0 / 0"
        
        gradientLayer.colors = [
            UIColor.black.withAlphaComponent(0.4).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0.1).cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        
        self.layer.cornerRadius = 12
        self.layer.masksToBounds = true
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func addChild() {
        self.addSubview(pageLabel)
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            pageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            pageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            pageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
    
    func updatePage(_ current: Int, total: Int) {
        pageLabel.text = "\(current) / \(total)"
    }
}
