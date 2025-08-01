//
//  LikeButton.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class LikeButton: BaseButton {
    
    override func addAttributes() {
        self.tintColor = Color.green
        self.setImage(Icons.heart, for: .normal)
        self.setImage(Icons.heartFill, for: .selected)
    }
}
