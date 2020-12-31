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

/// The `ScannerViewController` offers an interface to give feedback to the user regarding quadrilaterals that are detected. It also gives the user the opportunity to capture an image with a detected rectangle.
final class ScannerViewController: UIViewController {
    
    private var captureSessionManager: CaptureSessionManager?
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    /// The view that shows the focus rectangle (when the user taps to focus, similar to the Camera app)
    private var focusRectangle: FocusRectangleView!
    
    /// The view that draws the detected rectangles.
    private let quadView = QuadrilateralView()
        
    /// Whether flash is enabled
    private var flashEnabled = false
    
    /// The original bar style that was set by the host app
    private var originalBarStyle: UIBarStyle?
    
    private let bottomViewHeight:CGFloat = (142.0 + SafeAreaInsetsBottom)
    
    private lazy var previewFrame: CGRect = {
        let rect:CGRect = CGRect(x: 0, y: NavBarHeight, width: ScreenWidth, height: ScreenHeight - NavBarHeight - bottomViewHeight)
        return rect
    }()
    
    private lazy var topView: UIView = {
        let _topView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: NavBarHeight + 60.0));
        _topView.backgroundColor = .black
        return _topView
    }()
    
    private lazy var bottomView: UIView = {
        let _bottomView = UIView(frame: CGRect(x: 0, y: previewFrame.maxY, width: ScreenWidth, height: bottomViewHeight));
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
        let _imagePickView = UIImageView()
        _imagePickView.backgroundColor = .black
//        _imagePickView.layer.cornerRadius = 6
//        _imagePickView.layer.borderColor = UIColor.white.cgColor
//        _imagePickView.layer.borderWidth = 1
//        _imagePickView.layer.masksToBounds = true
        _imagePickView.contentMode = .scaleAspectFill
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
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = nil
        
        ScannerEventManager.event(withName: scanner_step1_view, parameters: nil)
        
        setupViews()
        setupNavigationBar()
        setupConstraints()
        
        captureSessionManager = CaptureSessionManager(videoPreviewLayer: videoPreviewLayer, delegate: self)
        
        originalBarStyle = navigationController?.navigationBar.barStyle
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: Notification.Name.AVCaptureDeviceSubjectAreaDidChange, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
        CaptureSession.current.isEditing = false
        quadView.removeQuadrilateral()
        captureSessionManager?.start()
        UIApplication.shared.isIdleTimerDisabled = true
        
//        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer.frame = quadView.frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
        
        navigationController?.setNavigationBarHidden(false, animated: true)
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.navigationBar.barStyle = originalBarStyle ?? .default
        captureSessionManager?.stop()
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        if device.torchMode == .on {
            toggleFlash()
        }
    }
    
    // MARK: - Setups
    
    private func setupViews() {
        view.backgroundColor = .darkGray
        view.layer.addSublayer(videoPreviewLayer)
        quadView.translatesAutoresizingMaskIntoConstraints = false
        quadView.editable = false
        view.addSubview(topView)
        topView.addSubview(flashButton)
        topView.addSubview(gridButton)
        topView.addSubview(topCenterView)
        view.addSubview(bottomView)
        view.addSubview(quadView)
        bottomView.addSubview(cancelButton)
        bottomView.addSubview(shutterButton)
        bottomView.addSubview(imagePickView)
        view.addSubview(activityIndicator)
        
        quadView.insertSubview(self.cameraGridView, at: 1)
        
        shutterButton.addTarget(self, action: #selector(captureImage(_:)), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelImageScannerController), for: .touchUpInside)
        flashButton.addTarget(self, action: #selector(toggleFlash), for: .touchUpInside)
        gridButton.addTarget(self, action: #selector(cameraView(btn:)), for: .touchUpInside)
        self.quadView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapTouch(tap:))))
//        self.imagePickView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImagePickVC(tap:))))
        self.imagePickView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fetchPermission(tap:))))
        
        self.topCenterView.btnSelectedBlock = {(type) in
            ScannerEventManager.event(withName: type == .auto ? scanner_step1_auto_click : scanner_step1_manual_click, parameters: nil)
            CaptureSession.current.isAutoScanEnabled = type == .auto
        }
        
//        PermissionsTool.request(toAccessPhotosSuccess: {
//            self.firstPHAsset { (image) in
//                self.imagePickView.image = image
//            }
//        }) {
//
//        }
        self.imagePickView.image = UIImage(named: "scan-image-icon")
    }
    
    private func setupNavigationBar() {
//        navigationItem.setLeftBarButton(flashButton, animated: false)
//        navigationItem.setRightBarButton(autoScanButton, animated: false)
//
//        if UIImagePickerController.isFlashAvailable(for: .rear) == false {
//            let flashOffImage = UIImage(named: "flashUnavailable", in: Bundle(for: ScannerViewController.self), compatibleWith: nil)
//            flashButton.image = flashOffImage
//            flashButton.tintColor = UIColor.lightGray
//        }
    }
    
    private func setupConstraints() {
        
        quadView.mas_makeConstraints { (maker) in
            maker?.left.right()?.equalTo()(self.view)
            maker?.top.equalTo()(self.topView.mas_bottom)
            maker?.bottom.equalTo()(self.bottomView.mas_top)
        }
        
        gridButton.mas_makeConstraints { (maker) in
            maker?.left.equalTo()(self.topView)?.offset()(24)
            maker?.bottom.equalTo()(self.topView)?.offset()(-35)
            maker?.size.equalTo()(CGSize(width: 30, height: 30))
        }
        
        topCenterView.mas_makeConstraints { (maker) in
            maker?.centerY.equalTo()(self.gridButton)
            maker?.centerX.equalTo()(self.topView)
        }
        
        flashButton.mas_makeConstraints { (maker) in
            maker?.right.equalTo()(self.topView)?.offset()(-24)
            maker?.bottom.equalTo()(self.gridButton)
            maker?.size.equalTo()(CGSize(width: 30, height: 30))
        }

        cancelButton.mas_makeConstraints { (maker) in
            maker?.left.equalTo()(self.bottomView)?.offset()(24)
            maker?.top.equalTo()(self.bottomView)?.offset()(56)
            maker?.size.equalTo()(CGSize(width: 30, height: 30))
        }
        
        
        shutterButton.mas_makeConstraints { (maker) in
            maker?.centerX.equalTo()(self.bottomView)
            maker?.centerY.equalTo()(self.cancelButton)
            maker?.size.equalTo()(CGSize(width: 80, height: 80))
        }
        
        imagePickView.mas_makeConstraints { (maker) in
            maker?.right.equalTo()(self.bottomView)?.offset()(-24)
            maker?.centerY.equalTo()(self.cancelButton)
            maker?.size.equalTo()(CGSize(width: 46, height: 46))
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
    
//    MARK: - 获取权限
    @objc func fetchPermission(tap:UITapGestureRecognizer) {
        PermissionsTool.request(toAccessPhotosSuccess: {
            self.showImagePickVC(tap: tap)
        }) {
            
        }
    }
    
    @objc func showImagePickVC(tap:UITapGestureRecognizer){
        self.captureSessionManager?.stop()
        let imagePickerVC = UIImagePickerController();
        imagePickerVC.delegate = self;
        imagePickerVC.modalPresentationStyle = .fullScreen
        imagePickerVC.sourceType = .photoLibrary;
        imagePickerVC.mediaTypes = [kUTTypeImage as String];
        self.present(imagePickerVC, animated: true, completion: nil)
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
        
        let editVC = EditScanViewController(image: picture, quad: quad)
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
    func firstPHAsset(complete:(@escaping (_ image:UIImage?) -> Void)) {
        let option = PHFetchOptions();
        //ascending 为YES时，按照照片的创建时间升序排列;为NO时，则降序排列
        option.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)];
        DispatchQueue.global(qos: .userInteractive).async {
            let result = PHAsset.fetchAssets(with: .image, options: option)
            guard result.count > 0 else{
                return
            }
            let asset = result.firstObject;
            PHCachingImageManager.default().requestImage(for: asset!, targetSize: CGSize(width: 200, height: 200), contentMode: .default, options: nil) { (image, imageInfo) in
                DispatchQueue.main.async {
                    complete(image)
                }
            }
        }
    }
    
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
