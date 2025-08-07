//
//  IndicatorContainer.swift
//  Cinely
//
//  Created by hwan on 8/5/25.
//

import UIKit
import Design

extension BaseViewController {
    func setIndicator(indicator: IndicatorContainerView) {
        self.view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            indicator.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            indicator.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            indicator.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            indicator.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}


final class IndicatorContainerView: BaseView {
    private(set) var indicator = UIActivityIndicatorView()
    
    override func addChild() {
        self.addSubview(indicator)
    }
    
    override func addAttributes() {
        self.backgroundColor = .black.withAlphaComponent(0.4)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.style = .large
        indicator.color = Color.green
        addLayout()
    }
    
    private func addLayout() {
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}


//final class IndicatorContainerViewController: BaseViewController {
//    private(set) var indicator = UIActivityIndicatorView()
//    private(set) var uuid = UUID()
//    
//    override func addChild() {
//        self.view.addSubview(indicator)
//    }
//    
//    override func addAttributes() {
//        self.view.backgroundColor = .black.withAlphaComponent(0.4)
//        indicator.translatesAutoresizingMaskIntoConstraints = false
//        indicator.style = .large
//        indicator.color = Color.green
//        addLayout()
//    }
//    
//    override func addLayout() {
//        NSLayoutConstraint.activate([
//            indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
//        ])
//    }
//}
