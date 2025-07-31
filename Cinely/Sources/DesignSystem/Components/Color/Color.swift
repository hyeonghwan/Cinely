//
//  Color.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit

enum Color {
    static let green =      UIColor(hex: 0x98FB98)
    static let lightGray =  UIColor(hex: 0xE1E1E1)
    static let mediumGray = UIColor(hex: 0x8E8E8E)
    static let black =      UIColor(hex: 0x000000)
    static let white =      UIColor(hex: 0xFFFFFF)
}

extension UIColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat) {
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: a)
    }
    
    convenience init(hex: Int) {
        self.init(r: (hex & 0xff0000) >> 16, g: (hex & 0xff00) >> 8, b: (hex & 0xff), a: 1)
    }
}
