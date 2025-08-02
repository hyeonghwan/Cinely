//
//  BackDropFooterView.swift
//  Cinely
//
//  Created by hwan on 8/2/25.
//

import UIKit
import Design

final class BackDropFooterView: BaseReusableView, CellIdentifialble {

    private let horizontalStackView = UIStackView()
    private let dateImageView = UIImageView()
    private let dateLabel = UILabel()
    private let ratingImageView = UIImageView()
    private let ratingLabel = UILabel()
    private let genreImageView = UIImageView()
    private let genreLabel = UILabel()
    private let separatorLabel1 = UILabel()
    private let separatorLabel2 = UILabel()

    override func addAttributes() {
        horizontalStackView.spacing = 4
        let iconConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        dateImageView.image = Icons.calendar?.withConfiguration(iconConfig)
        ratingImageView.image = Icons.starFill?.withConfiguration(iconConfig)
        genreImageView.image = Icons.filmFill?.withConfiguration(iconConfig)

        [dateImageView, ratingImageView, genreImageView].forEach {
            $0.tintColor = Color.mediumGray.withAlphaComponent(0.6)
            $0.contentMode = .scaleAspectFit
        }
        [dateLabel, ratingLabel, genreLabel, separatorLabel1, separatorLabel2].forEach {
            $0.textColor = Color.mediumGray.withAlphaComponent(0.6)
            $0.font = Font.thin12
        }
        separatorLabel1.text = " | "
        separatorLabel2.text = " | "
    }
    
    override func addChild() {
        self.addSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(dateImageView)
        horizontalStackView.addArrangedSubview(dateLabel)
        
        horizontalStackView.addArrangedSubview(separatorLabel1)
        
        horizontalStackView.addArrangedSubview(ratingImageView)
        horizontalStackView.addArrangedSubview(ratingLabel)
        
        horizontalStackView.addArrangedSubview(separatorLabel2)
        
        horizontalStackView.addArrangedSubview(genreImageView)
        horizontalStackView.addArrangedSubview(genreLabel)
        
        horizontalStackView.translatesAutoresizingMaskIntoConstraints = false
    }

    override func addLayout() {
        NSLayoutConstraint.activate([
            horizontalStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            horizontalStackView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }

    public func set(date: String = "2024-12-24", rating: Double = 8.0, genres: String = "액션, 스릴러") {
        dateLabel.text = date
        ratingLabel.text = String(format: "%.1f", rating)
        genreLabel.text = genres
    }
}

