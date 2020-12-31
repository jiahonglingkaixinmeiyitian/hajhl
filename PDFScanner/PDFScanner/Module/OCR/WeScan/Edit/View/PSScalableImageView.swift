//
//  PSScalableImageView.swift
//  PDFScanner
//
//  Created by Dfsx on 2020/12/25.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

enum RotationDirection {
    
    case clockwise // 顺时针
    case counterClockwise // 逆时针
}

class PSScalableImageView: UIView {

    var rotationAngle:Double = 0.0
    
    var scalableImage: UIImage? {
        didSet {
            guard let scalableImage = scalableImage else { return }
            imageView.image = scalableImage
            imageView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalTo(self.imageView.snp.height).multipliedBy(scalableImage.size.width / scalableImage.size.height)
                make.top.greaterThanOrEqualToSuperview().offset(imagePadding.top)
                make.left.greaterThanOrEqualToSuperview().offset(imagePadding.left)
            }
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let _scrollView = UIScrollView()
        _scrollView.clipsToBounds = false
        _scrollView.delegate = self
        _scrollView.minimumZoomScale = 1
        _scrollView.maximumZoomScale = 6
        return _scrollView
    }()
    
    lazy var imageView: SignatureImageView = {
        let _imageView = SignatureImageView()
        _imageView.contentMode = .scaleAspectFit
        return _imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }
    
    fileprivate func setUp() {
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        scrollView.addSubview(imageView)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleClick))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }

    @objc func doubleClick(sender: UITapGestureRecognizer) {
        
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        } else {
            let location = sender.location(in: self)
            scrollView.zoom(to: CGRect(origin: location, size: .zero), animated: true)
        }
    }
    
    func rotate(direction: RotationDirection) {
        
        if direction == .clockwise {
            //
            self.rotationAngle += 90.0
        } else {
            self.rotationAngle -= 90.0
        }
        self.rotationAngle.formTruncatingRemainder(dividingBy: 360)
        
        UIView.animate(withDuration: 0.3) {
            //
            
            let result = Measurement(value: self.rotationAngle, unit: UnitAngle.degrees)

            self.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
            
            var imageSize = self.scalableImage!.size
            if Int(self.rotationAngle / 90).isOdd {
                imageSize = CGSize(width: self.scalableImage!.size.height, height: self.scalableImage!.size.width)
            }
            let size = UIImage.generateFittingSizeForImageSize(imageSize, inContainerSize: self.bounds.size, aroundPadding: .zero)
            var scale = CGFloat(1)
            if size.width > size.height {
                scale = size.width / self.width
            } else if size.width < size.height {
                scale = size.height / self.height
            } else {
                // size width = size height
                scale = size.height / min(self.size.width, self.size.height)
            }

            self.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.transform)
        }
    }
    
    func zoomToNormal() {
        
        self.scrollView.zoomScale = 1.0
    }
    
}

extension PSScalableImageView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

/// 添加签名的ImageView, 签名View可以拖动到UIImageView并且响应用户事件
class SignatureImageView: UIImageView {
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        
        guard let boardView = self.subviews.filter({$0 is BoardView}).first else {
            return super.hitTest(point, with: event)
        }
        
        let pointForTargetView = boardView.convert(point, from: self)
        
        return boardView.hitTest(pointForTargetView, with: event)
    }
}
