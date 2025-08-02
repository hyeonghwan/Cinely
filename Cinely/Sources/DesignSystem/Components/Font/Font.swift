//
//  Font.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit


enum Font {
    static let thin12: UIFont = .systemFont(ofSize: 12, weight: .thin)
    static let thin14: UIFont = .systemFont(ofSize: 14, weight: .thin)
    static let thin17: UIFont = .systemFont(ofSize: 17, weight: .thin)
    static let thin24: UIFont = .systemFont(ofSize: 24, weight: .thin)
    
    static let light12: UIFont = .systemFont(ofSize: 12, weight: .light)
    static let light14: UIFont = .systemFont(ofSize: 14, weight: .light)
    static let light17: UIFont = .systemFont(ofSize: 17, weight: .light)
    static let light24: UIFont = .systemFont(ofSize: 24, weight: .light)
    
    static let regular14: UIFont = .systemFont(ofSize: 14, weight: .regular)
    static let regular17: UIFont = .systemFont(ofSize: 17, weight: .regular)
    static let regular24: UIFont = .systemFont(ofSize: 24, weight: .regular)
    
    static let semiBold14: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    static let semiBold17: UIFont = .systemFont(ofSize: 17, weight: .semibold)
    static let semiBold24: UIFont = .systemFont(ofSize: 24, weight: .semibold)
    
    static let bold14: UIFont = .systemFont(ofSize: 14, weight: .bold)
    static let bold17: UIFont = .systemFont(ofSize: 17, weight: .bold)
    static let bold21: UIFont = .systemFont(ofSize: 21, weight: .bold)
    static let bold24: UIFont = .systemFont(ofSize: 24, weight: .bold)
    
    static var italic35: UIFont {
        if let descriptor = UIFont.systemFont(ofSize: 35).fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            let boldItalicFont = UIFont(descriptor: descriptor, size: 35)
            return boldItalicFont
        } else {
            return .systemFont(ofSize: 35, weight: .bold)
        }
    }
}

