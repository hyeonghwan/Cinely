//
//  BottomLayeredTextField.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit

final class BottomLayerTextField: UITextField {
    
    var btBorderHeight: CGFloat = 1
    var btBorderColor: CGColor = UIColor.white.cgColor
    
    private var bottomLayer: CALayer! = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textAlignment = .center
        if #available(iOS 17.0 ,*) {
            observeLayout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bottomLayer == nil {
            bottomLayer = CAShapeLayer()
            bottomLayer.frame = CGRect(
                x: 0.0,
                y: self.bounds.height - btBorderHeight,
                width: self.bounds.width,
                height: btBorderHeight
            )
            bottomLayer.backgroundColor = btBorderColor
            self.layer.addSublayer(bottomLayer)
        }
    }
    
    @available(iOS 17.0, *)
    private func observeLayout() {
        let sizeTraits: [UITrait] = [UITraitVerticalSizeClass.self, UITraitHorizontalSizeClass.self]
        registerForTraitChanges(sizeTraits) { (self: Self, previousTraitCollection: UITraitCollection) in
            self.bottomLayer.removeFromSuperlayer()
            self.bottomLayer = nil
            self.setNeedsLayout()
        }
    }
}
