//
//  BAButton.swift
//  BAButtonDemo
//
//  Created by Adam Bella on 8/26/19.
//  Copyright © 2019 Bella Ádám. All rights reserved.
//

import UIKit

enum AnimationType {

    case none
    case touchCenterCircleFill
    case touchCenterFill
    case verticalCenterFill
    case horizontalCenterFill
    case bottomToTopFill
    case topToBottomFill

}

@IBDesignable
class BAButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue?.cgColor
        }
        get {
            guard let color = layer.borderColor else {
                return nil
            }
            return UIColor(cgColor: color)
        }
    }

    @IBInspectable var inkColor = UIColor(red: 181 / 255, green: 164 / 255, blue: 208 / 255, alpha: 0.6) {
        didSet {
            inkLayer.fillColor = inkColor.cgColor
        }
    }

    var animationType = AnimationType.touchCenterCircleFill
    private let inkLayer = CAShapeLayer()
    private let inkAnimation = CABasicAnimation(keyPath: "path")

    override func awakeFromNib() {
        super.awakeFromNib()
        commonInit()
    }

}

private extension BAButton {

    final func commonInit() {
        inkLayer.fillColor = inkColor.cgColor
        layer.insertSublayer(inkLayer, at: 0)
        addTarget(self, action: #selector(didTouchDown), for: .touchDown)
        addTarget(self, action: #selector(didTouchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(didTouchUpInside), for: .touchUpInside)
        addTarget(self, action: #selector(didCancelTouchs), for: .touchCancel)
    }

    @objc func didTouchDown(_ sender: UIButton, forEvent event: UIEvent) {
        beginInkAnimation(on: event.allTouches?.first?.location(in: self))
    }

    @objc func didTouchUpOutside(_ sender: UIButton) {
        cancelInkAnimation()
    }

    @objc func didTouchUpInside(_ sender: UIButton) {
        cancelInkAnimation()
    }

    @objc func didCancelTouchs(_ sender: UIButton) {
        cancelInkAnimation()
    }

    // MARK: - Animation

    final func beginInkAnimation(on startPosition: CGPoint?) {
        let inkStartPosition = startPosition ?? CGPoint.zero
        inkLayer.path = createStartShape(on: inkStartPosition).cgPath
        inkAnimation.toValue = createEndShape(on: inkStartPosition).cgPath
        inkAnimation.duration = 0.5
        inkAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        inkAnimation.fillMode = .both
        inkAnimation.isRemovedOnCompletion = false
        inkLayer.add(inkAnimation, forKey: inkAnimation.keyPath)
    }

    final func cancelInkAnimation() {
        inkLayer.removeAnimation(forKey: inkAnimation.keyPath!)
    }

    final func createStartShape(on startPosition: CGPoint) -> UIBezierPath {
        switch animationType {
        case .touchCenterCircleFill:
            return UIBezierPath(roundedRect: CGRect(origin: startPosition, size: CGSize.zero), cornerRadius: 0)
        case .touchCenterFill:
            return UIBezierPath(roundedRect: CGRect(origin: startPosition, size: CGSize.zero), cornerRadius: 0)
        case .verticalCenterFill:
            return UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: bounds.height / 2), size: CGSize(width: bounds.width, height: 0)), cornerRadius: 0)
        case .horizontalCenterFill:
            return UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: bounds.width / 2, y: 0), size: CGSize(width: 0, height: bounds.height)), cornerRadius: bounds.height / 2)
        case .bottomToTopFill:
            return UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: 0, y: bounds.height), size: CGSize(width: bounds.width, height: bounds.height)), cornerRadius: 0)
        case .topToBottomFill:
            return UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: 0)), cornerRadius: 0)
        case .none:
            return UIBezierPath(roundedRect: CGRect.zero, cornerRadius: 0)
        }
    }

    final func createEndShape(on startPosition: CGPoint) -> UIBezierPath {
        switch animationType {
        case .touchCenterCircleFill:
            let maxDimension = max(bounds.width, bounds.height) + (abs(startPosition.x - bounds.width / 2) + abs(startPosition.y - bounds.height / 2)) * 2
            let halfMaxDimension = maxDimension / 2
            return UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: startPosition.x - halfMaxDimension, y: startPosition.y - halfMaxDimension), size: CGSize(width: maxDimension, height: maxDimension)), cornerRadius: halfMaxDimension)
        case .touchCenterFill:
             return UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), cornerRadius: bounds.height / 2)
        case .verticalCenterFill:
             return UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: bounds.height)), cornerRadius: 0)
        case .horizontalCenterFill:
             return UIBezierPath(roundedRect: CGRect(origin: CGPoint.zero, size: CGSize(width: bounds.width, height: bounds.height)), cornerRadius: bounds.height / 2)
        case .bottomToTopFill:
             return UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), cornerRadius: 0)
        case .topToBottomFill:
             return UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height), cornerRadius: 0)
        case .none:
            return UIBezierPath(roundedRect: CGRect.zero, cornerRadius: 0)
        }
    }

}
