//
//  BackDropFooterView.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class BackDropFooterView: BaseReusableView, CellIdentifialble {
    
    private class ImageLabelContainer: BaseView {
        fileprivate let imageView = UIImageView()
        fileprivate let label = UILabel()
        
        override func addChild() {
            self.addSubview(imageView)
            self.addSubview(label)
            imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            imageView.setContentCompressionResistancePriority(.required, for: .vertical)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            label.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 6),
                label.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                imageView.topAnchor.constraint(equalTo: self.topAnchor),
                imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        
        override func addAttributes() {
            label.textColor = Color.mediumGray.withAlphaComponent(0.6)
            label.font = Font.thin12
            imageView.image = Icons.calendar?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .medium))
            imageView.tintColor = Color.mediumGray.withAlphaComponent(0.6)
            imageView.contentMode = .scaleAspectFit
        }
        
        fileprivate func setModel(text: String) {
            label.text = text
        }
    }
    
    private let containerView = UIView()
    private let dateContainer = ImageLabelContainer()
    private let ratingContainer = ImageLabelContainer()
    private let genreContainer = ImageLabelContainer()
    private let separatorLabel1 = UILabel()
    private let separatorLabel2 = UILabel()

    override func addAttributes() {
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        dateContainer.imageView.image = Icons.calendar?.withConfiguration(iconConfig)
        ratingContainer.imageView.image = Icons.starFill?.withConfiguration(iconConfig)
        genreContainer.imageView.image = Icons.filmFill?.withConfiguration(iconConfig)

        genreContainer.label.numberOfLines = 3
        separatorLabel1.text = " | "
        separatorLabel2.text = " | "
        
        separatorLabel1.textColor = Color.mediumGray.withAlphaComponent(0.6)
        separatorLabel1.font = Font.thin12
        
        separatorLabel2.textColor = Color.mediumGray.withAlphaComponent(0.6)
        separatorLabel2.font = Font.thin12
    }
    
    override func addChild() {
        self.addSubview(containerView)
        self.containerView.addSubview(dateContainer)
        self.containerView.addSubview(ratingContainer)
        self.containerView.addSubview(genreContainer)
        self.containerView.addSubview(separatorLabel1)
        self.containerView.addSubview(separatorLabel2)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.translatesAutoresizingMaskIntoConstraints = false
        ratingContainer.translatesAutoresizingMaskIntoConstraints = false
        genreContainer.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel1.translatesAutoresizingMaskIntoConstraints = false
        separatorLabel2.translatesAutoresizingMaskIntoConstraints = false
    }

    override func addLayout() {
        separatorLabel1.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        separatorLabel2.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        let maxWidth = UIScreen.main.bounds.width - 16
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            containerView.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth),
            
            dateContainer.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            ratingContainer.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            genreContainer.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            separatorLabel1.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            separatorLabel2.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor),
            
            separatorLabel1.trailingAnchor.constraint(equalTo: ratingContainer.leadingAnchor, constant: -6),
            separatorLabel2.leadingAnchor.constraint(equalTo: ratingContainer.trailingAnchor, constant: 6),
            
            dateContainer.trailingAnchor.constraint(equalTo: separatorLabel1.leadingAnchor, constant: -6),
            genreContainer.leadingAnchor.constraint(equalTo: separatorLabel2.trailingAnchor, constant: 6),
            
            dateContainer.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor),
            genreContainer.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor)
        ])
    }

    func set(date: String, rating: Double, genres: String) {
        dateContainer.setModel(text: date)
        ratingContainer.setModel(text: String(format: "%.1f", rating))
        genreContainer.setModel(text: genres)
    }
}

