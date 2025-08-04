//
//  UILabel+.swift
//  Cinely
//
//  Created by hwan on 8/4/25.
//

import UIKit
import HwanKit

extension UILabel {
    func isTruncated() -> Bool {
        guard let text = self.text else { return false }
        let maxSize = CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: self.font!]
        let textSize = (text as NSString).boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: textAttributes, context: nil).size
        return textSize.height > self.bounds.height
    }
}


