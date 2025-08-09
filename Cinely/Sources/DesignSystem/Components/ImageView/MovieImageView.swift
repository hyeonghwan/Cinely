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
    static var options: KingfisherOptionsInfo = [
        .transition(.fade(0.3)),
        .scaleFactor(UIScreen.main.scale),
        .cacheOriginalImage,
        .memoryCacheExpiration(.days(7)),
        .diskCacheExpiration(.days(30)),
        .callbackQueue(.mainAsync)
    ]
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.contentMode = .scaleAspectFit
        self.kf.indicatorType = .activity
    }
    
    required init?(coder: NSCoder) { fatalError("never called") }
    
    func setDefaultImage(image: UIImage) {
        self.image = image
    }
    
    func setKFImage(image: String, size: CGSize) {
        if let url = URL(string: image) {
            var options = Self.options
            options.append(.processor(DownsamplingImageProcessor(size: size)))
            let cacheKey = url.absoluteString
            let resources = KF.ImageResource(downloadURL: url, cacheKey: cacheKey)
            (self as UIImageView).kf.setImage(
                with: resources,
                placeholder: nil,
                options: options
            )
        } else {
            self.image = Icons.filmFill?
                .withTintColor(
                    .white,
                    renderingMode: .alwaysOriginal
                )
        }
    }    
}
