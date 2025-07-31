//
//  RoundedButton.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class GreenLayerButton: BaseButton {
    
    convenience init(title: String) {
        self.init(frame: .zero)
        defer {
            self.setAttributedTitle(NSAttributedString(
                string: title,
                attributes: [.font : Font.semiBold17 ]
            ), for: .normal)
        }
    }
    
    override func addAttributes() {
        self.backgroundColor = .clear
        self.setTitleColor(.systemGreen, for: .normal)
        self.layer.cornerRadius = 21
        self.layer.borderWidth = 1
        self.layer.borderColor = Color.green.cgColor
    }
}
