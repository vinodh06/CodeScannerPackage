//
//  ScannerBoundingBoxView.swift
//  ScannerPOC
//
//  Created by vinodh kumar on 10/05/23.
//

import UIKit

class CodeScannerBoundingBoxView: UIView {

    var lineWidth: CGFloat
    var lineColor: UIColor
    var lineCap: CAShapeLayerLineCap
    var maskSize: CGSize
    var animationDuration: Double

    init(frame: CGRect = .zero, lineWidth: CGFloat = 1, lineColor: UIColor = .white, lineCap: CAShapeLayerLineCap = CAShapeLayerLineCap.round, maskSize: CGSize = .zero, animationDuration: Double = 0.5) {
        self.lineWidth = lineWidth
        self.lineColor = lineColor
        self.lineCap = lineCap
        self.maskSize = maskSize
        self.animationDuration = animationDuration

        super.init(frame: frame)

        setupBorderLayer()
        addAnimatingBarInMask()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var maskContainer: CGRect {
        CGRect(x: (bounds.width / 2) - (maskSize.width / 2),
               y: (bounds.height / 2) - (maskSize.height / 2),
               width: maskSize.width,
               height: maskSize.height)
    }

    func setupBorderLayer() {
        let path = CGMutablePath()
        path.addRect(bounds)
        path.addRoundedRect(in: maskContainer, cornerWidth: layer.cornerRadius, cornerHeight: layer.cornerRadius)

        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.fillRule = .evenOdd
        layer.addSublayer(maskLayer)

        let rectPath = UIBezierPath(rect: maskContainer)
        let borderLayer = CAShapeLayer()
        borderLayer.path = rectPath.cgPath
        borderLayer.strokeColor = lineColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = lineWidth
        borderLayer.lineCap = lineCap
        layer.addSublayer(borderLayer)
    }

    func addAnimatingBarInMask() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: maskContainer.minX, y: maskContainer.minY, width: maskContainer.width, height: maskContainer.height / 2)
        gradientLayer.colors = [lineColor.withAlphaComponent(0.5).cgColor,
                                lineColor.withAlphaComponent(0.2).cgColor,
                                lineColor.withAlphaComponent(0.1).cgColor,
                                lineColor.withAlphaComponent(0.05).cgColor,
                                UIColor.clear.cgColor
        ]
        layer.addSublayer(gradientLayer)

        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = NSNumber(value: maskContainer.minY + maskContainer.height / 4)
        animation.toValue = NSNumber(value: maskContainer.maxY - maskContainer.height / 16)
        animation.duration = animationDuration
        animation.repeatCount = .infinity
        animation.autoreverses = true
        gradientLayer.add(animation, forKey: "position.y")
    }
}

