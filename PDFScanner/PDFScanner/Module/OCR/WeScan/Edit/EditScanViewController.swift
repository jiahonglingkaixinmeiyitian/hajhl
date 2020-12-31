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
    
    static let leftMargin : CGFloat = 24.0
    static let topMargin : CGFloat = 87.0
    static let bottomMargin : CGFloat = 145.0
    private let defaultQuad:Quadrilateral
    private var isAll : Bool = false
    
    var editRowIndex:Int = -1
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isOpaque = true
        imageView.image = image
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var quadView: QuadrilateralView = {
        let quadView = QuadrilateralView()
        quadView.editable = true
        quadView.translatesAutoresizingMaskIntoConstraints = false
        return quadView
    }()
    
    private lazy var editBottomView: EditBottomView = {
        let _editBottomView : EditBottomView = EditBottomView.loadXib()!
        _editBottomView.bottomViewType = .firstStep
        return _editBottomView
    }()
    
    private lazy var nextButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.next", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Next", comment: "A generic next button")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(pushStepTwoVC))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let title = NSLocalizedString("wescan.edit.button.cancel", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Cancel", comment: "A generic cancel button")
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(cancelButtonTapped))
        button.tintColor = navigationController?.navigationBar.tintColor
        return button
    }()
    
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
        
        //        title = NSLocalizedString("wescan.edit.title", tableName: nil, bundle: Bundle(for: EditScanViewController.self), value: "Edit Scan", comment: "The title of the EditScanViewController")
        //        navigationItem.rightBarButtonItem = nextButton
        //        if let firstVC = self.navigationController?.viewControllers.first, firstVC == self {
        //            navigationItem.leftBarButtonItem = cancelButton
        //        } else {
        //            navigationItem.leftBarButtonItem = nil
        //        }
        
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
        view.addSubview(imageView)
        view.addSubview(quadView)
        view.addSubview(editBottomView)
        self.safeBottomView.backgroundColor = self.editBottomView.backgroundColor;
        
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Work around for an iOS 11.2 bug where UIBarButtonItems don't get back to their normal state after being pressed.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }
        
    private func setupConstraints() {
        imageView.mas_makeConstraints { (maker) in
            maker?.centerX.equalTo()(view)
            maker?.top.equalTo()(view)?.offset()(EditScanViewController.topMargin)
            maker?.width.equalTo()(ScreenWidth - 2*EditScanViewController.leftMargin)
            maker?.height.equalTo()(0)
        }
        
        quadView.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(imageView)
        }
        
        editBottomView.mas_makeConstraints { (maker) in
            maker?.left.right()?.equalTo()(self.safeBottomView)
            maker?.bottom.equalTo()(self.safeBottomView.mas_top)
            maker?.height.equalTo()(58)
        }
    }
    
    private func updateConstraints() {
        let imageSize = self.image.size
        
        var imageViewHeight = self.view.height - self.editBottomView.height - self.safeBottomViewHeight - EditScanViewController.topMargin - EditScanViewController.bottomMargin
        var top:CGFloat = 87
        var imageViewWidth = ScreenWidth - 2*EditScanViewController.leftMargin
        if (imageSize.height/imageSize.width) > (imageViewHeight/imageViewWidth){
            imageViewWidth = imageViewHeight * imageSize.width / imageSize.height
        }else{
            imageViewHeight = imageSize.height * imageViewWidth / imageSize.width
            top = (self.view.height - self.editBottomView.height - self.safeBottomViewHeight - imageViewHeight)/2
        }
        imageView.mas_updateConstraints { (maker) in
            maker?.top.equalTo()(view)?.offset()(top)
            maker?.width.equalTo()(imageViewWidth)
            maker?.height.equalTo()(imageViewHeight)
        }
    }
    
    // MARK: - Actions
    private func allClick(){
        self.isAll = !self.isAll
        self.displayQuad()
        ScannerEventManager.event(withName: scanner_step2_all_click, parameters: nil)
    }
    
    private func leftClick(){
        self.rotationAngle -= 90.0
        if self.rotationAngle == -360.0{
            self.rotationAngle = 0
        }
        self.transformRotationAngle()
        ScannerEventManager.event(withName: scanner_step2_left_click, parameters: nil)
    }
    
    private func rightClick(){
        self.rotationAngle += 90.0
        if self.rotationAngle == 360.0{
            self.rotationAngle = 0
        }
        self.transformRotationAngle()
        ScannerEventManager.event(withName: scanner_step2_right_click, parameters: nil)
    }
    
    private func transformRotationAngle(){
        let result = Measurement(value: self.rotationAngle, unit: UnitAngle.degrees)
        
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
        self.quadView.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
        
        var scale:CGFloat = 1.0
        if Int(self.rotationAngle/90)%2 != 0 && self.imageView.width > ScreenWidth - 2*EditScanViewController.leftMargin{
            scale = (ScreenWidth - 2*EditScanViewController.leftMargin)/self.imageView.width
        }
        self.imageView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.imageView.transform)
        self.quadView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.quadView.transform)
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
            var selectedImage = originImage
            var selectedRow = 0
            if let data = GPUFilterHander.sharedInstance.getSelectedFilter(){
                selectedImage = GPUFilterHander.getFilterImage(originImage: selectedImage, filter: data.1.0) ?? selectedImage
                selectedRow = data.0
            }
            DispatchQueue.main.async {
                self.ps_hideProgressHUDForWindow()
                let stepTwoVC = EditScanStepTwoVC()
                stepTwoVC.image = originImage
                stepTwoVC.selectedImage = selectedImage
                stepTwoVC.selectedIndex = IndexPath(row: selectedRow, section: 0)
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
