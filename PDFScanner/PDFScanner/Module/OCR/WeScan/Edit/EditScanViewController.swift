//
//  EditScanViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation
import GPUImage
import SnapKit

/// The `EditScanViewController` offers an interface for the user to edit the detected quadrilateral.
final class EditScanViewController: PSBaseVC {
    
    private var rotationAngle:Double = 0.0
    
    /// The image the quadrilateral was detected on.
    private let image: UIImage
    
    /// The detected quadrilateral that can be edited by the user. Uses the image's coordinates.
    private var quad: Quadrilateral
    
    private var zoomGestureController: ZoomGestureController!
    
    private var quadViewWidthConstraint = NSLayoutConstraint()
    private var quadViewHeightConstraint = NSLayoutConstraint()
    
    let editBottomViewHeight: CGFloat = 58
    private let defaultQuad:Quadrilateral
    private var isAll : Bool = false
    
    var editRowIndex:Int = -1
    
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        return quadView
    }()
    
    private lazy var editBottomView: EditBottomView = {
        let _editBottomView : EditBottomView = EditBottomView.loadXib()!
        _editBottomView.bottomViewType = .firstStep
        return _editBottomView
    }()
    
    var containerSize: CGSize {
        return CGSize(width: ScreenWidth, height: ScreenHeight - NavBarHeight - editBottomViewHeight - keyWindowSafeArea.bottom)
    }
    
    // MARK: - Life Cycle
    
    init(image: UIImage, quad: Quadrilateral?, rotateImage: Bool = true) {
        self.image = rotateImage ? image.applyingPortraitOrientation() : image
        self.defaultQuad = EditScanViewController.defaultQuad(forImage: image)
        self.quad = quad ?? EditScanViewController.defaultQuad(forImage: image)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.colorWithHexString(colorString: "#EEF1F8")
                
        zoomGestureController = ZoomGestureController(image: image, quadView: quadView)
        
        let touchDown = UILongPressGestureRecognizer(target: zoomGestureController, action: #selector(zoomGestureController.handle(pan:)))
        touchDown.minimumPressDuration = 0
        quadView.addGestureRecognizer(touchDown)
        
        ScannerEventManager.event(withName: scanner_step2_view, parameters: nil)
    }
    
    // MARK: - Setups
    
    override func setupViews()
    {
        self.needTitleView = true
        super.setupViews()
        view.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(editBottomView)
        self.safeBottomView.backgroundColor = self.editBottomView.backgroundColor
        
        editBottomView.btnClickBlock = {[weak self] (index, _) in
            switch index {
            case 0:
                self?.allClick()
            case 1:
                self?.leftClick()
            case 2:
                self?.rightClick()
            case 3:
                self?.pushStepTwoVC()
            default:
                break
            }
        }
        
        setupConstraints()
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustQuadViewConstraints()
        displayQuad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Work around for an iOS 11.2 bug where UIBarButtonItems don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
        
    private func setupConstraints() {
        
        imageContainerView.snp.makeConstraints { (maker) in
            maker.top.right.left.equalToSuperview()
            maker.bottom.equalTo(self.editBottomView.snp.top)
        }
        
        let imageSize = UIImage.generateFittingSizeForImageSize(self.image.size, inContainerSize: containerSize, aroundPadding: imagePadding)
        imageView.snp.makeConstraints { (maker) in
            maker.center.equalToSuperview()
            maker.size.equalTo(imageSize)
        }
        
        quadView.snp.makeConstraints { (maker) in
            maker.edges.equalTo(self.imageView)
        }
        
        editBottomView.snp.makeConstraints { (maker) in
            maker.left.right.equalToSuperview()
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.height.equalTo(self.editBottomViewHeight)
        }

        imageView.setNeedsLayout()
        imageView.layoutIfNeeded()
    }
    
    // MARK: - Actions
    private func allClick(){
        self.isAll.toggle()
        self.displayQuad()
        ScannerEventManager.event(withName: scanner_step2_all_click, parameters: nil)
    }
    
    private func leftClick(){
        self.rotationAngle -= 90.0
        self.rotationAngle.formTruncatingRemainder(dividingBy: 360)
        self.transformRotationAngle()
        ScannerEventManager.event(withName: scanner_step2_left_click, parameters: nil)
    }
    
    private func rightClick(){
        self.rotationAngle += 90.0
        self.rotationAngle.formTruncatingRemainder(dividingBy: 360)
        self.transformRotationAngle()
        ScannerEventManager.event(withName: scanner_step2_right_click, parameters: nil)
    }
    
    private func transformRotationAngle() {
        
        UIView.animate(withDuration: 0.3) {
            //
            let result = Measurement(value: self.rotationAngle, unit: UnitAngle.degrees)

            self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
            self.quadView.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
            
            var imageSize = self.image.size
            if Int(self.rotationAngle / 90).isOdd {
                imageSize = CGSize(width: self.image.size.height, height: self.image.size.width)
            }
            let size = UIImage.generateFittingSizeForImageSize(imageSize, inContainerSize: self.containerSize, aroundPadding: imagePadding)
            var scale = CGFloat(1)
            if size.width > size.height {
                scale = size.width / self.imageView.width
            } else {
                scale = size.height / self.imageView.height
            }

            self.imageView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.imageView.transform)
            self.quadView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.quadView.transform)
        }
        
    }
    
    @objc func cancelButtonTapped() {
        if let imageScannerController = navigationController as? ImageScannerController {
            imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
        }
    }
    
    @objc func pushStepTwoVC() {
        ScannerEventManager.event(withName: scanner_step2_continue_click, parameters: nil)
        guard let quad = quadView.quad,
            let ciImage = CIImage(image: image) else {
                if let imageScannerController = navigationController as? ImageScannerController {
                    let error = ImageScannerControllerError.ciImageCreation
                    imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
                }
                return
        }
        
        let quadViewSize = self.quadView.bounds.size
        self.ps_showProgressHUDInWindow()
        DispatchQueue.global().async {
            let cgOrientation = CGImagePropertyOrientation(self.image.imageOrientation)
            let orientedImage = ciImage.oriented(forExifOrientation: Int32(cgOrientation.rawValue))
            let scaledQuad = quad.scale(quadViewSize, self.image.size)
            self.quad = scaledQuad
            
            // Cropped Image
            var cartesianScaledQuad = scaledQuad.toCartesian(withHeight: self.image.size.height)
            cartesianScaledQuad.reorganize()
            
            let filteredImage = orientedImage.applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: cartesianScaledQuad.bottomLeft),
                "inputTopRight": CIVector(cgPoint: cartesianScaledQuad.bottomRight),
                "inputBottomLeft": CIVector(cgPoint: cartesianScaledQuad.topLeft),
                "inputBottomRight": CIVector(cgPoint: cartesianScaledQuad.topRight)
            ])
            
            let croppedImage = UIImage.from(ciImage: filteredImage)
            // Enhanced Image
//            let enhancedImage = filteredImage.applyingAdaptiveThreshold()?.withFixedOrientation()
            //        let enhancedScan = enhancedImage.flatMap { ImageScannerScan(image: $0) }
            
            //        let rotatedImage = image.rotated(by: Measurement<UnitAngle>(value: self.rotationAngle, unit: .degrees)) ?? image
            let rotatedcroppedImage = croppedImage.rotated(by: Measurement<UnitAngle>(value: self.rotationAngle, unit: .degrees)) ?? self.image
            //        let results = ImageScannerResults(detectedRectangle: scaledQuad, originalScan: ImageScannerScan(image: rotatedImage), croppedScan: ImageScannerScan(image: rotatedcroppedImage), enhancedScan: enhancedScan)
            var originImage = rotatedcroppedImage
            if let settingModel = PSScannerSettingModel.allObjects().firstObject() as? PSScannerSettingModel{
                originImage = originImage.compress(byte: Int(settingModel.phoneCompressionByte()))
            }
            let images = GPUFilterHander.sharedInstance.getFilterImages(image: originImage)

            DispatchQueue.main.async {
                self.ps_hideProgressHUDForWindow()
                let stepTwoVC = EditScanStepTwoVC()
                stepTwoVC.image = originImage
                stepTwoVC.editRowIndex = self.editRowIndex
                stepTwoVC.filterImages = images
                stepTwoVC.filters = GPUFilterHander.sharedInstance.filters
                self.navigationController?.pushViewController(stepTwoVC, animated: true)
            }
        }
    }
    
    private func displayQuad() {
        let imageSize = image.size
        let imageFrame = CGRect(origin: quadView.frame.origin, size: CGSize(width: quadViewWidthConstraint.constant, height: quadViewHeightConstraint.constant))
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: imageSize, aspectFillInSize: imageFrame.size)
        let transforms = [scaleTransform]
        let transformedQuad = self.isAll ? self.defaultQuad.applyTransforms(transforms) : quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: false)
    }
    
    /// The quadView should be lined up on top of the actual image displayed by the imageView.
    /// Since there is no way to know the size of that image before run time, we adjust the constraints to make sure that the quadView is on top of the displayed image.
    private func adjustQuadViewConstraints() {
        let frame = AVMakeRect(aspectRatio: image.size, insideRect: imageView.bounds)
        quadViewWidthConstraint.constant = frame.size.width
        quadViewHeightConstraint.constant = frame.size.height
    }
    
    /// Generates a `Quadrilateral` object that's centered and one third of the size of the passed in image.
    private static func defaultQuad(forImage image: UIImage) -> Quadrilateral {
        let topLeft = CGPoint(x: 0, y: image.size.height)
        let topRight = CGPoint(x: image.size.width, y: image.size.height)
        let bottomRight = CGPoint(x: image.size.width, y: 0.0)
        let bottomLeft = CGPoint(x: 0, y: 0)
        
        //        let topLeft = CGPoint(x: image.size.width / 3.0, y: image.size.height / 3.0)
        //        let topRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: image.size.height / 3.0)
        //        let bottomRight = CGPoint(x: 2.0 * image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        //        let bottomLeft = CGPoint(x: image.size.width / 3.0, y: 2.0 * image.size.height / 3.0)
        //
        let quad = Quadrilateral(topLeft: topLeft, topRight: topRight, bottomRight: bottomRight, bottomLeft: bottomLeft)
        
        return quad
    }
    
}
