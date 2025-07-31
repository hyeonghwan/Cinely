//
//  OnboardingViewController.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit
import Design

final class OnboardingViewController: BaseViewController {
    private let onboardingImageView = MovieImageView()
    private let onboardingLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let startButton = GreenLayerButton(title: "시작하기")
    
    override func addAttributes() {
        setDefaultBackground()
        
        self.onboardingImageView.setDefaultImage(image: UIImage(resource: ImageResource.splash))
        
        onboardingLabel.textColor = Color.white
        onboardingLabel.font = Font.italic35
        onboardingLabel.text = "Onboarding"
        
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = Font.thin14
        descriptionLabel.text = """
        당신만의 영화 세상,
        Cinely를 시작해보세요
        """
        descriptionLabel.numberOfLines = 2
    }
    
    override func addChild() {
        self.view.addSubview(onboardingImageView)
        self.view.addSubview(onboardingLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(startButton)
        onboardingImageView.translatesAutoresizingMaskIntoConstraints = false
        onboardingLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        startButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func addLayout() {
        let img = onboardingImageView
        NSLayoutConstraint.activate([
            img.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.65),
            img.heightAnchor.constraint(equalTo: img.widthAnchor),
            img.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            img.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
            
            onboardingLabel.topAnchor.constraint(equalTo: img.bottomAnchor, constant: 120),
            onboardingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            descriptionLabel.topAnchor.constraint(equalTo: onboardingLabel.bottomAnchor, constant: 24),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            startButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 44),
            startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            startButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    override func binding() {
        
    }
}
