//
//  UIView+Extension.swift
//  Movie Theater
//
//  Created by Federico Vitale on 28/11/2019.
//  Copyright © 2019 Federico Vitale. All rights reserved.
//

import Foundation
import UIKit

/*
 * -----------------------
 * MARK: - Utility
 * ------------------------
 */
extension UIView {
    enum Axis {
        case x
        case y
    }
    
    func hide() {
        alpha = 0
        isUserInteractionEnabled = false
    }
    
    func show() {
        alpha = 1
        isUserInteractionEnabled = true
    }
    
    func addParallaxEffect(x: Int = 20, y: Int = 20) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -x
        horizontal.maximumRelativeValue = x
        
        let vertical = UIInterpolatingMotionEffect(keyPath: "layer.transform.translation.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -y
        vertical.maximumRelativeValue = y
        
        let motionEffectsGroup = UIMotionEffectGroup()
        motionEffectsGroup.motionEffects = [horizontal, vertical]
        
        addMotionEffect(motionEffectsGroup)
    }
    
    @discardableResult
    func setConstraints(_ constraints: [NSLayoutConstraint]) -> UIView {
        guard let _ = superview else {
            return self
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
        return self
    }
    
    @discardableResult
    func setConstraints(_ constraints: NSLayoutConstraint...) -> UIView {
        guard let _ = superview else {
            return self
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
        return self
    }
    
    @discardableResult
    func centerInSuperView(_ x: CGFloat = 0, _ y: CGFloat = 0) -> UIView {
        guard let superView = superview else { return self }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        return setConstraints([
            centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: x),
            centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: y)
        ])
    }
    
    @discardableResult
    func fillSuperView(axis: Axis, constant: CGFloat = 0) -> UIView {
        guard let superView = superview else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        
        switch axis {
        case .x:
            return setConstraints([
                trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: -constant),
                leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: constant),
            ])
        case .y:
            return setConstraints([
                topAnchor.constraint(equalTo: superView.topAnchor, constant: constant),
                bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: -constant)
            ])
        }
    }
    
    @discardableResult
    func centerInSuperView(axis: Axis, constant: CGFloat = 0) -> UIView {
        guard let superView = superview else { return self }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if axis == .x {
            return setConstraints([
                centerXAnchor.constraint(equalTo: superView.centerXAnchor, constant: constant)
            ])
        }
        
        return setConstraints([
            centerYAnchor.constraint(equalTo: superView.centerYAnchor, constant: constant)
        ])
    }
    
    @discardableResult
    func setSize(w: CGFloat, h: CGFloat) -> UIView {
        translatesAutoresizingMaskIntoConstraints = false
        
        return setConstraints([
            widthAnchor.constraint(equalToConstant: w),
            heightAnchor.constraint(equalToConstant: h)
        ])
    }
    
    @discardableResult
    func setPosition(top: CGFloat? = nil, right: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil) -> UIView {
        guard let superView = superview else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        
        var newConstraints: [NSLayoutConstraint] = []
        
        if let top = top {
            newConstraints.append(topAnchor.constraint(equalTo: superView.topAnchor, constant: top))
        }
        
        if let right = right {
            newConstraints.append(rightAnchor.constraint(equalTo: superView.rightAnchor, constant: right))
        }
        
        if let bottom = bottom {
            newConstraints.append(bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom))
        }
        
        if let left = left {
            newConstraints.append(leftAnchor.constraint(equalTo: superView.leftAnchor, constant: left))
        }
        
        return setConstraints(newConstraints)
    }
    
    @discardableResult
    func fillSuperView(top: CGFloat = 0, right: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0) -> UIView {
        guard let superView = superview else { return self }
        translatesAutoresizingMaskIntoConstraints = false
        return setConstraints([
            topAnchor.constraint(equalTo: superView.topAnchor, constant: top),
            trailingAnchor.constraint(equalTo: superView.trailingAnchor, constant: right),
            leadingAnchor.constraint(equalTo: superView.leadingAnchor, constant: left),
            bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: bottom)
        ])
    }
    
    
    @discardableResult
    func addToView(_ view: UIView) -> UIView {
        view.addSubview(self)
        return self
    }
    
    @discardableResult
    func bringToFront() -> UIView {
        guard let superView = superview else { return self }
        superView.bringSubviewToFront(self)
        return self
    }
    
    
    func addShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.2, radius: CGFloat = 5) {
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = offset
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
    }
}

extension CALayer {
    func addShadow(offset: CGSize = CGSize(width: 0, height: 0), opacity: Float = 0.2, radius: CGFloat = 5) {
        shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        shadowColor = UIColor.black.cgColor
        shadowOffset = offset
        shadowRadius = radius
        shadowOpacity = opacity
    }
}

