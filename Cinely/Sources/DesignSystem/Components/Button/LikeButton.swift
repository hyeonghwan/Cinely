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
        let normal = Icons.heart
        let selected = Icons.heartFill
        self.setImage(normal, for: .normal)
        self.setImage(selected, for: .selected)
        let pointSize: CGFloat = 23
        let imageConfig = UIImage.SymbolConfiguration(pointSize: pointSize)
        var config = UIButton.Configuration.plain()
        config.preferredSymbolConfigurationForImage = imageConfig
        config.background.backgroundColor = .clear
        self.configuration = config
    }
}
