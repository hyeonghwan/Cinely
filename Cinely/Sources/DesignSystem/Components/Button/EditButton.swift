//
//  EditButton.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class EditButton: BaseButton {
    
    convenience init(title: String) {
        self.init(frame: .zero)
        defer { self.setTitle(title, for: .normal) }
    }
    
    override func addAttributes() {
        self.backgroundColor = .clear
        self.setTitleColor(.white, for: .normal)
        self.layer.cornerRadius = 21
        self.layer.borderWidth = 1
        self.layer.borderColor = Color.white.cgColor
    }
}

