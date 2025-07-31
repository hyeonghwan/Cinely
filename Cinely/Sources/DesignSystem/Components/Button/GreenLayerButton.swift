//
//  RoundedButton.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class GreenButton: BaseButton {
    
    convenience init(title: String) {
        self.init(frame: .zero)
        defer { self.setTitle(title, for: .normal) }
    }
    
    override func addAttributes() {
        self.backgroundColor = .clear
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.systemGreen.cgColor
    }
}
