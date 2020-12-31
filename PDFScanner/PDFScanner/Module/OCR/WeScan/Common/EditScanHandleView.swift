//
//  EditScanHandleView.swift
//  WeScan
//
//  Created by Boris Emorine on 3/5/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit

/// Simple enum to keep track of the position of the handles of a quadrilateral.
enum HandlePosition {
    case left
    case top
    case right
    case bottom
}

/// A UIView used by handles of a quadrilateral that is aware of its position.
final class EditScanHandleView: UIView {
    
    let position: HandlePosition
    
    /// The image to display when the handle view is highlighted.
//    private var image: UIImage?
//    private(set) var isHighlighted = false
    
    private lazy var rectangleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.allowsEdgeAntialiasing = true
        layer.masksToBounds = true
        layer.fillColor = UIColor.white.cgColor
        layer.strokeColor = UIColor.colorWithHexString(colorString: "#D13D1E").cgColor
        layer.lineWidth = 2.0
        return layer
    }()
    
    init(frame: CGRect, position: HandlePosition) {
        self.position = position
        super.init(frame: frame)
        backgroundColor = UIColor.white
        clipsToBounds = true
        layer.masksToBounds = true
        layer.allowsEdgeAntialiasing = true
        layer.addSublayer(rectangleLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let cornerRadius = min(rect.width, rect.height) / 2.0 - rectangleLayer.lineWidth
        let bezierPath = UIBezierPath(roundedRect: rect.insetBy(dx: rectangleLayer.lineWidth, dy: rectangleLayer.lineWidth), cornerRadius: cornerRadius)
        rectangleLayer.frame = rect
        rectangleLayer.path = bezierPath.cgPath
        
//        image?.draw(in: rect)
    }
    
//    func highlightWithImage(_ image: UIImage) {
//        isHighlighted = true
//        self.image = image
//        self.setNeedsDisplay()
//    }
//
//    func reset() {
//        isHighlighted = false
//        image = nil
//        setNeedsDisplay()
//    }
    
    func fillShape(isFilled: Bool) {
        
        rectangleLayer.fillColor = isFilled ? rectangleLayer.strokeColor : UIColor.white.cgColor
    }
    
}
