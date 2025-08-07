//
//  BottomLayeredTextField.swift
//  Cinely
//
//  Created by hwan on 7/31/25.
//

import UIKit

final class BottomLayerTextField: UITextField {
    
    var btBorderHeight: CGFloat = 1
    var btBorderColor: CGColor = Color.white.cgColor {
        didSet {
            if oldValue != self.btBorderColor {
                self.setNeedsDisplay()
            }
        }
    }
    
    private var bottomLayer: CALayer! = nil
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        self.textAlignment = .center
        if #available(iOS 17.0 ,*) {
            observeLayout()
        }
        self.textAlignment = .left
        self.font = Font.regular14
        self.textColor = Color.white
        self.tintColor = Color.white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        if bottomLayer != nil {
            bottomLayer.removeFromSuperlayer()
        }
        bottomLayer = CAShapeLayer()
        bottomLayer.frame = CGRect(
            x: -8,
            y: self.bounds.height - btBorderHeight,
            width: self.bounds.width + 8.0,
            height: btBorderHeight
        )
        bottomLayer.backgroundColor = btBorderColor
        self.layer.addSublayer(bottomLayer)
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
