//
//  TabbarController.swift
//  Cinely
//
//  Created by hwan on 8/6/25.
//

import UIKit

class CustomTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if #available(iOS 18, *) {
            guard let fromView = selectedViewController?.view,
                  let toView = viewController.view,
                  fromView != toView else {
                return viewController != selectedViewController
            }
            UIView.transition(
                from: fromView, to: toView,
                duration: 0.01,
                options: [.transitionCrossDissolve]
            ) { _ in }
            return viewController != selectedViewController
        }
        
        return true
    }
}
