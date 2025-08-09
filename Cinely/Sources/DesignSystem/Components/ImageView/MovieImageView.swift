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
            self.kf.indicatorType = .activity
            let cacheKey = url.absoluteString
            let resources = KF.ImageResource(downloadURL: url, cacheKey: cacheKey)
            (self as UIImageView).kf.setImage(
                with: resources,
                placeholder: nil,
                options: [
                    .transition(.fade(0.3)),
                    .processor(DownsamplingImageProcessor(size: size)),
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .memoryCacheExpiration(.days(7)),
                    .diskCacheExpiration(.days(30)),
                    .callbackQueue(.mainAsync)
                ]
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
