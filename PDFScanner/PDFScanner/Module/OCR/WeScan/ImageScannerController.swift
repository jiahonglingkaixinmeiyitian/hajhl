//
//  ImageScannerController.swift
//  WeScan
//
//  Created by Boris Emorine on 2/12/18.
//  Copyright © 2018 WeTransfer. All rights reserved.
//

import UIKit
import AVFoundation
import Realm

/// A set of methods that your delegate object must implement to interact with the image scanner interface.
@objc
public protocol ImageScannerControllerDelegate: NSObjectProtocol {
    /// Tells the delegate that the user scanned a document.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    ///   - results: The results of the user scanning with the camera.
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
//    func imageScannerController(_ scanner: ImageScannerController, didFinishScanningWithResults results: ImageScannerResults)
    
    /// Tells the delegate that the user cancelled the scan operation.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    /// - Discussion: Your delegate's implementation of this method should dismiss the image scanner controller.
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController)
    
    /// Tells the delegate that an error occured during the user's scanning experience.
    ///
    /// - Parameters:
    ///   - scanner: The scanner controller object managing the scanning interface.
    ///   - error: The error that occured.
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error)
    
   
    @objc optional func editScanStepTwoDone(image:UIImage, scanner: ImageScannerController, edit:Bool)
}

/// A view controller that manages the full flow for scanning documents.
/// The `ImageScannerController` class is meant to be presented. It consists of a series of 3 different screens which guide the user:
/// 1. Uses the camera to capture an image with a rectangle that has been detected.
/// 2. Edit the detected rectangle.
/// 3. Review the cropped down version of the rectangle.

@objcMembers public final class ImageScannerController: PSBaseNavigationVC {
    
    /// The object that acts as the delegate of the `ImageScannerController`.
    public weak var imageScannerDelegate: ImageScannerControllerDelegate?
    
    public var selectedDirectory:PSFileModel!{
        didSet{
            if !selectedDirectory.isDir{
                self.titleStr = selectedDirectory.name
            }
        }
    }
    
    public var titleStr:String?
    
    // MARK: - Life Cycle
    
    /// A black UIView, used to quickly display a black screen when the shutter button is presseed.
//    internal let blackFlashView: UIView = {
//        let view = UIView()
//        view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
//        view.isHidden = true
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    public convenience init(rootViewController: UIViewController, titleStr:String?) {
        self.init(rootViewController:rootViewController)
        self.titleStr = titleStr
        self.configVCTitleStr(vc: rootViewController)
    }
    
    public override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        self.imageScannerDelegate = rootViewController as? ImageScannerControllerDelegate
    }
    
    @objc public convenience init(delegate: ImageScannerControllerDelegate?) {
        self.init(image:nil, delegate: delegate);
    }
    
    public required init(image: UIImage? = nil, delegate: ImageScannerControllerDelegate? = nil) {
        super.init(rootViewController: ScannerViewController())
        
        self.imageScannerDelegate = delegate
        
//        if #available(iOS 13.0, *) {
//            navigationBar.tintColor = .label
//        } else {
//            navigationBar.tintColor = .black
//        }
//        navigationBar.isTranslucent = false
//        self.view.addSubview(blackFlashView)
//        setupConstraints()
        
        // If an image was passed in by the host app (e.g. picked from the photo library), use it instead of the document scanner.
//        if let image = image {
//
//            var detectedQuad: Quadrilateral?
//
//            // Whether or not we detect a quad, present the edit view controller after attempting to detect a quad.
//            // *** Vision *requires* a completion block to detect rectangles, but it's instant.
//            // *** When using Vision, we'll present the normal edit view controller first, then present the updated edit view controller later.
//
//            guard let ciImage = CIImage(image: image) else { return }
//            let orientation = CGImagePropertyOrientation(image.imageOrientation)
//            let orientedImage = ciImage.oriented(forExifOrientation: Int32(orientation.rawValue))
//            if #available(iOS 11.0, *) {
//
//                // Use the VisionRectangleDetector on iOS 11 to attempt to find a rectangle from the initial image.
//                VisionRectangleDetector.rectangle(forImage: ciImage, orientation: orientation) { (quad) in
//                    detectedQuad = quad?.toCartesian(withHeight: orientedImage.extent.height)
//                    let editViewController = EditScanViewController(image: image, quad: detectedQuad, rotateImage: false)
//                    self.setViewControllers([editViewController], animated: true)
//                }
//            } else {
//                // Use the CIRectangleDetector on iOS 10 to attempt to find a rectangle from the initial image.
//                detectedQuad = CIRectangleDetector.rectangle(forImage: ciImage)?.toCartesian(withHeight: orientedImage.extent.height)
//                let editViewController = EditScanViewController(image: image, quad: detectedQuad, rotateImage: false)
//                setViewControllers([editViewController], animated: false)
//            }
//        }
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: true)
        self.configVCTitleStr(vc: viewController)
    }
    
    public override func popViewController(animated: Bool) -> UIViewController? {
        let viewController = super.popViewController(animated: animated)
        self.configVCTitleStr(vc: self.viewControllers.last)
        return viewController
    }
    
    public override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let vcs = super.popToViewController(viewController, animated: animated)
        self.configVCTitleStr(vc: self.viewControllers.last)
        return vcs
    }
    
    public override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let vcs = super.popToRootViewController(animated: animated)
        self.configVCTitleStr(vc: self.viewControllers.last)
        return vcs
    }
    
    func configVCTitleStr(vc:UIViewController?){
        if let title = self.titleStr, let vc = vc as? PSBaseVC{
            vc.titleStr = title
            if vc.titleViewClickBlock == nil{
                vc.titleViewClickBlock = { [unowned self] in
                    self.alertUpdateFileName()
                }
            }
        }
    }
}

extension ImageScannerController{
    func alertUpdateFileName() {
        let updateFileNameDialog = UIAlertController.init(title: "Edit File Name", message: "", preferredStyle: .alert)
        updateFileNameDialog.addTextField { (tf) in
            tf.placeholder = self.titleStr
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let updateAction =  UIAlertAction(title: "Sure", style: .default, handler: { (_) in
            if let text = updateFileNameDialog.textFields?.first?.text, text.count > 0{
                self.titleStr = text
                self.configVCTitleStr(vc: self.viewControllers.last)
                if !self.selectedDirectory.isDir{
                    do {
                        try RLMRealm.default().transaction {
                            self.selectedDirectory.name = self.titleStr ?? ""
                        }
                    } catch{}
                }
            }
            else{
                self.ps_showHint("File Name Can't be empty")
            }
        })
        
        updateFileNameDialog.addAction(cancelAction)
        updateFileNameDialog.addAction(updateAction)
        self.present(updateFileNameDialog, animated: true, completion: nil)
    }
}

/// Data structure containing information about a scan, including both the image and an optional PDF.
public struct ImageScannerScan {
    public enum ImageScannerError: Error {
        case failedToGeneratePDF
    }
    
    public var image: UIImage
    
    public func generatePDFData(completion: @escaping (Result<Data, ImageScannerError>) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async {
            if let pdfData = self.image.pdfData() {
                completion(.success(pdfData))
            } else {
                completion(.failure(.failedToGeneratePDF))
            }
        }
        
    }
    
    mutating func rotate(by rotationAngle: Measurement<UnitAngle>) {
        guard rotationAngle.value != 0, rotationAngle.value != 360 else { return }
        image = image.rotated(by: rotationAngle) ?? image
    }
}

/// Data structure containing information about a scanning session.
/// Includes the original scan, cropped scan, detected rectangle, and whether the user selected the enhanced scan. May also include an enhanced scan if no errors were encountered.
public struct ImageScannerResults {
    
    /// The original scan taken by the user, prior to the cropping applied by WeScan.
    public var originalScan: ImageScannerScan
    
    /// The deskewed and cropped scan using the detected rectangle, without any filters.
    public var croppedScan: ImageScannerScan
    
    /// The enhanced scan, passed through an Adaptive Thresholding function. This image will always be grayscale and may not always be available.
    public var enhancedScan: ImageScannerScan?
    
    /// Whether the user selected the enhanced scan or not.
    /// The `enhancedScan` may still be available even if it has not been selected by the user.
    public var doesUserPreferEnhancedScan: Bool
    
    /// The detected rectangle which was used to generate the `scannedImage`.
    public var detectedRectangle: Quadrilateral
    
    @available(*, unavailable, renamed: "originalScan")
    public var originalImage: UIImage?
    
    @available(*, unavailable, renamed: "croppedScan")
    public var scannedImage: UIImage?
    
    @available(*, unavailable, renamed: "enhancedScan")
    public var enhancedImage: UIImage?
    
    @available(*, unavailable, renamed: "doesUserPreferEnhancedScan")
    public var doesUserPreferEnhancedImage: Bool = false
    
    init(detectedRectangle: Quadrilateral, originalScan: ImageScannerScan, croppedScan: ImageScannerScan, enhancedScan: ImageScannerScan?, doesUserPreferEnhancedScan: Bool = false) {
        self.detectedRectangle = detectedRectangle
        
        self.originalScan = originalScan
        self.croppedScan = croppedScan
        self.enhancedScan = enhancedScan
        
        self.doesUserPreferEnhancedScan = doesUserPreferEnhancedScan
    }
}
