//
//  ScannerViewController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/8/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation
import Masonry
import Photos
import CoreServices
import PhotosUI

/// The `ScannerViewController` offers an interface to give feedback to the user regarding quadrilaterals that are detected. It also gives the user the opportunity to capture an image with a detected rectangle.
final class ScannerViewController: PSBaseVC {
    
    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    /// The view that shows the focus rectangle (when the user taps to focus, similar to the Camera app)
    private var focusRectangle: FocusRectangleView!
    
    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()
        
    /// Whether flash is enabled
    private var flashEnabled = false
    
    /// The original bar tint color that was set by the host app
    private var originalBarTintColor: UIColor?
    
    private let bottomViewHeight:CGFloat = (98)
    
//    private lazy var previewFrame: CGRect = {
//        let rect:CGRect = CGRect(x: 0, y: NavBarHeight, width: ScreenWidth, height: ScreenHeight - NavBarHeight - bottomViewHeight)
//        return rect
//    }()
    
    private lazy var bottomView: UIView = {
        let _bottomView = UIView()
        _bottomView.backgroundColor = .black
        return _bottomView
    }()
    
    private lazy var shutterButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "icon_scann2_80_black"), for: .normal)
        button.layer.cornerRadius = 40.0
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_close_30_black"), for: .normal)
        return button
    }()
    
    private lazy var topCenterView: ScannerTopCenterView = {
        let _topCenterView:ScannerTopCenterView = ScannerTopCenterView.loadXib()!
        return _topCenterView
    }()
    
    private lazy var flashButton: UIButton = {
        let _flashButton = UIButton(type: .custom)
        _flashButton.setImage(UIImage(named: "icon_light_30_black"), for: .normal)
        _flashButton.setImage(UIImage(named: "icon_light_active_30_black"), for: .selected)
        _flashButton.setImage(UIImage(named: "icon_light_active_30_black"), for: UIControl.State(rawValue: UIControl.State.selected.rawValue | UIControl.State.highlighted.rawValue))
        return _flashButton
    }()
    
    private lazy var imagePickView: UIImageView = {
        let _imagePickView = UIImageView(image: UIImage(named: "icon_photo_white"))
        _imagePickView.backgroundColor = .black
        _imagePickView.layer.masksToBounds = true
        _imagePickView.contentMode = .center
        _imagePickView.isUserInteractionEnabled = true
        return _imagePickView
    }()
    
    private lazy var gridButton:UIButton = {
        let _gridButton = UIButton(type: .custom)
        _gridButton.adjustsImageWhenHighlighted = false
        _gridButton.setImage(UIImage(named: "icon_grid_30_black"), for: .normal)
        _gridButton.setImage(UIImage(named: "icon_grid_active_30_black"), for: .selected)
        _gridButton.setImage(UIImage(named: "icon_grid_active_30_black"), for: UIControl.State(rawValue: UIControl.State.selected.rawValue | UIControl.State.highlighted.rawValue))
        return _gridButton;
    }()
    
    private lazy var cameraGridView: DBCameraGridView = {
        let view = DBCameraGridView(frame: self.videoPreviewLayer.frame)
        view.autoresizingMask = UIView.AutoresizingMask(rawValue: UIView.AutoresizingMask.flexibleWidth.rawValue | UIView.AutoresizingMask.flexibleHeight.rawValue);
        view.numberOfColumns = 2;
        view.numberOfRows = 2;
        view.alpha = 0;
        return view
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.hidesWhenStopped = true
        return activityIndicator
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ScannerEventManager.event(withName: scanner_step1_view, parameters: nil)
        
        setupViews()
        setupNavigationBar()
        setupConstraints()
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, delegate: self)
        
        originalBarTintColor = navigationController?.navigationBar.barTintColor
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()

        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
        
        navigationController?.navigationBar.barTintColor = .black
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer.frame = quadView.frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        navigationController?.navigationBar.barTintColor = originalBarTintColor ?? .white
        captureSessionManager?.stop()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }
    
    // MARK: - Setups
    
    override func setupViews() {
        super.setupViews()
        self.safeBottomView.backgroundColor = .black
        view.backgroundColor = .black
        view.layer.addSublayer(videoPreviewLayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(bottomView)
        view.addSubview(quadView)
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(shutterButton)
        bottomView.addSubview(imagePickView)
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { (make) in
            make.center.equalTo(view)
        }
        
        quadView.insertSubview(self.cameraGridView, at: 1)
        
        shutterButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        gridButton.addTarget(self, action: #selector(cameraView(btn:)), for: .touchUpInside)
        self.quadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTouch(tap:))))
        self.imagePickView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImagePickVC(tap:))))
        
        self.topCenterView.btnSelectedBlock = {(type) in
            ScannerEventManager.event(withName: type == .auto ? scanner_step1_auto_click : scanner_step1_manual_click, parameters: nil)
            CaptureSession.current.isAutoScanEnabled = type == .auto
        }
    
    }
    
    private func setupNavigationBar() {
        
        topCenterView.layoutIfNeeded()
        topCenterView.setNeedsLayout()
        navigationItem.titleView = topCenterView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: gridButton)
        if !UIImagePickerController.isFlashAvailable(for: .rear) {
            flashButton.isEnabled = false
            flashButton.isSelected = false
            flashButton.tintColor = UIColor.lightGray
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flashButton)
        
    }
    
    private func setupConstraints() {
        
        quadView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.bottomView.snp.top)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            make.height.equalTo(self.bottomViewHeight)
        }

        cancelButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(24 * 2 + 24)
        }

        shutterButton.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }

        imagePickView.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(0)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(24 * 2 + 24)
        }
        
    }
    
    // MARK: - Tap to Focus
    
    /// Called when the AVCaptureDevice detects that the subject area has changed significantly. When it's called, we reset the focus so the camera is no longer out of focus.
    @objc private func subjectAreaDidChange() {
        /// Reset the focus and exposure back to automatic
        do {
            try CaptureSession.current.resetFocusToAuto()
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
        
        /// Remove the focus rectangle if one exists
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: true)
    }
    
    @objc func tapTouch(tap:UITapGestureRecognizer) {
        let touchPoint = tap.location(in: view)
        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
        
        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
        
        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
        view.addSubview(focusRectangle)
        
        do {
            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
        } catch {
            let error = ImageScannerControllerError.inputDevice
            guard let captureSessionManager = captureSessionManager else { return }
            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
            return
        }
    }
    
    @objc func showImagePickVC(tap:UITapGestureRecognizer){
        self.captureSessionManager?.stop()
        
        
        if #available(iOS 14, *) {
            var config = PHPickerConfiguration()
            config.filter = PHPickerFilter.images
            config.selectionLimit = 1
            let imagePickerVC = PHPickerViewController(configuration: config)
            imagePickerVC.delegate = self
            imagePickerVC.modalPresentationStyle = .fullScreen
            present(imagePickerVC, animated: true, completion: nil)
        } else {
            let imagePickerVC = UIImagePickerController();
            imagePickerVC.delegate = self;
            imagePickerVC.modalPresentationStyle = .fullScreen
            imagePickerVC.sourceType = .photoLibrary;
            imagePickerVC.mediaTypes = [kUTTypeImage as String];
            self.present(imagePickerVC, animated: true, completion: nil)
        }
        
        ScannerEventManager.event(withName: scanner_step1_cature_file_click, parameters: nil)
    }
    
    @objc func cameraView(btn:UIButton){
        btn.isSelected = !btn.isSelected;
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
            self.cameraGridView.alpha = (btn.isSelected ? 1.0 : 0.0);
        }, completion: nil)
    }    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//
//        guard  let touch = touches.first else { return }
//        let touchPoint = touch.location(in: view)
//        let convertedTouchPoint: CGPoint = videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
//
//        CaptureSession.current.removeFocusRectangleIfNeeded(focusRectangle, animated: false)
//
//        focusRectangle = FocusRectangleView(touchPoint: touchPoint)
//        view.addSubview(focusRectangle)
//
//        do {
//            try CaptureSession.current.setFocusPointToTapPoint(convertedTouchPoint)
//        } catch {
//            let error = ImageScannerControllerError.inputDevice
//            guard let captureSessionManager = captureSessionManager else { return }
//            captureSessionManager.delegate?.captureSessionManager(captureSessionManager, didFailWithError: error)
//            return
//        }
//    }
    
    // MARK: - Actions
    
    @objc private func captureImage(_ sender: UIButton) {
//        (navigationController as? ImageScannerController)?.flashToBlack()
        shutterButton.isUserInteractionEnabled = false
        captureSessionManager?.capturePhoto()
        ScannerEventManager.event(withName: scanner_step1_capture_click, parameters: nil)
    }
    
    @objc private func toggleAutoScan() {
        if CaptureSession.current.isAutoScanEnabled {
            CaptureSession.current.isAutoScanEnabled = false
            //autoScanButton.title = NSLocalizedString("wescan.scanning.manual", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Manual", comment: "The manual button state")
        } else {
            CaptureSession.current.isAutoScanEnabled = true
            //autoScanButton.title = NSLocalizedString("wescan.scanning.auto", tableName: nil, bundle: Bundle(for: ScannerViewController.self), value: "Auto", comment: "The auto button state")
        }
    }
    
    @objc private func toggleFlash() {
        self.flashButton.isSelected = !self.flashButton.isSelected
        let state = CaptureSession.current.toggleFlash()
        
        switch state {
        case .on:
            flashEnabled = true
            
        case .off:
            flashEnabled = false
            
        case .unknown, .unavailable:
            flashEnabled = false
           
        }
    }
    
    @objc private func cancelImageScannerController() {
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerControllerDidCancel(imageScannerController)
    }
    
}

extension ScannerViewController: RectangleDetectionDelegateProtocol {
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didFailWithError error: Error) {
        
        activityIndicator.stopAnimating()
        shutterButton.isUserInteractionEnabled = true
        
        guard let imageScannerController = navigationController as? ImageScannerController else { return }
        imageScannerController.imageScannerDelegate?.imageScannerController(imageScannerController, didFailWithError: error)
    }
    
    func didStartCapturingPicture(for captureSessionManager: CaptureSessionManager) {
        activityIndicator.startAnimating()
        captureSessionManager.stop()
        shutterButton.isUserInteractionEnabled = false
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didCapturePicture picture: UIImage, withQuad quad: Quadrilateral?) {
        activityIndicator.stopAnimating()
        
        var reorganizedQuad = quad
        reorganizedQuad?.reorganize()
        let editVC = EditScanViewController(image: picture, quad: reorganizedQuad, rotateImage: false)
        navigationController?.pushViewController(editVC, animated: false)
        
        shutterButton.isUserInteractionEnabled = true
    }
    
    func captureSessionManager(_ captureSessionManager: CaptureSessionManager, didDetectQuad quad: Quadrilateral?, _ imageSize: CGSize) {
        guard let quad = quad else {
            // If no quad has been detected, we remove the currently displayed on on the quadView.
            quadView.removeQuadrilateral()
            return
        }
        
        let portraitImageSize = CGSize(width: imageSize.height, height: imageSize.width)
        
        let scaleTransform = CGAffineTransform.scaleTransform(forSize: portraitImageSize, aspectFillInSize: quadView.bounds.size)
        let scaledImageSize = imageSize.applying(scaleTransform)
        
        let rotationTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2.0)

        let imageBounds = CGRect(origin: .zero, size: scaledImageSize).applying(rotationTransform)

        let translationTransform = CGAffineTransform.translateTransform(fromCenterOfRect: imageBounds, toCenterOfRect: quadView.bounds)
        
        let transforms = [scaleTransform, rotationTransform, translationTransform]
        
        let transformedQuad = quad.applyTransforms(transforms)
        
        quadView.drawQuadrilateral(quad: transformedQuad, animated: true)
    }
    
}

extension ScannerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var image = info[.originalImage] as? UIImage else { return }
        self.ps_showProgressHUDInWindow()
        DispatchQueue.global().async {
            let settingModel = PSScannerSettingModel.allObjects().firstObject()   
            image = image.compress(byte: Int(settingModel?.phoneCompressionByte() ?? 2285373))
            DispatchQueue.main.async {
                self.ps_hideProgressHUDForWindow()
                self.pushEditVC(image: image)
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.captureSessionManager?.start()
    }
    
    func pushEditVC(image:UIImage){
         var detectedQuad: Quadrilateral?
         
         // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
         // *** Vision *requires* a completion block to detect rectangles, but it's instant.
         // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.
        
         guard let ciImage = CIImage(image: image) else { return }
         let orientation = CGImagePropertyOrientation(image.imageOrientation)
         let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
         if #available(iOS 11.0, *) {
             
             // Use the VisionRectangleDetector on iOS 11 to attempt to find a rectangle from the initial image.
             VisionRectangleDetector.rectangle(forImage: ciImage, orientation: orientation) { (quad) in
                 detectedQuad = quad?.toCartesian(withHeight: orientedImage.extent.height)
                 let editViewController = EditScanViewController(image: image, quad: detectedQuad, rotateImage: false)
                 self.navigationController?.pushViewController(editViewController, animated: true)
             }
         } else {
             // Use the CIRectangleDetector on iOS 10 to attempt to find a rectangle from the initial image.
             detectedQuad = CIRectangleDetector.rectangle(forImage: ciImage)?.toCartesian(withHeight: orientedImage.extent.height)
             let editViewController = EditScanViewController(image: image, quad: detectedQuad, rotateImage: false)
             self.navigationController?.pushViewController(editViewController, animated: true)
         }

    }
}

@available(iOS 14, *)
extension ScannerViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let result = results.first {
            
            ps_showProgressHUDInWindow()
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                //
                DispatchQueue.main.async {
                    
                    self.ps_hideProgressHUDForWindow()
                    
                    if var image = object as? UIImage {
                        
                        let settingModel = PSScannerSettingModel.allObjects().firstObject()
                        image = image.compress(byte: Int(settingModel?.phoneCompressionByte() ?? 2285373))
                        
                        self.pushEditVC(image: image)
                        picker.dismiss(animated: true, completion: nil)
                    } else {
                        self.ps_showHint(error?.localizedDescription)
                    }
                    
                }
            })
        }
        
    }
}
