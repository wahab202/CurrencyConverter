//
//  UIView+EXT.swift
//  CurrencyConverter
//
//  Created by Abdul Wahab on 02/01/2024.
//

import UIKit

protocol Fadable where Self: UIView {
    func fadeIn(animated: Bool)
    func fadeOut(animated: Bool)
    
    func fade(alpha value: CGFloat, animated: Bool)
}

extension Fadable {
    func fadeIn(animated: Bool = true) {
        fade(alpha: 0.4, animated: animated)
    }
    
    func fadeOut(animated: Bool = true) {
        fade(alpha: 1, animated: animated)
    }

    func fade(alpha value: CGFloat, animated: Bool = true) {
        let actions = {
            self.alpha = value
        }
        
        if animated {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                usingSpringWithDamping: 1,
                initialSpringVelocity: 0.2,
                options: [
                    .allowUserInteraction,
                        .curveEaseOut,
                        .beginFromCurrentState
                ],
                animations: actions,
                completion: nil
            )
        } else {
            actions()
        }
    }
}
