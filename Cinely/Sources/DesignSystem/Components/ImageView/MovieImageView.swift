//
//  MovieImageView.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design
import Kingfisher

final class MovieImageView: UIImageView {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
    }
    
    required init?(coder: NSCoder) { fatalError("never called") }
    
    func setDefaultImage(image: UIImage) {
        self.image = image
    }
    
    func setKFImage(image: String, size: CGSize) {
        if let url = URL(string: image) {
            (self as UIImageView).kf.downSizingImage(url: url, size: size)
        } else {
            self.image = Icons.filmFill?
                .withTintColor(
                    .white,
                    renderingMode: .alwaysOriginal
                )
        }
    }    
}
