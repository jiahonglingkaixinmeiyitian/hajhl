//
//  EditScanStepTwoVC.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/9.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import GPUImage
import Realm

class EditScanStepTwoVC: PSBaseVC {
    
    private var rotationAngle:Double = 0.0

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    enum FilterSliderType:Int {
        case brightness, contrast
    }
    
    var image: UIImage!
    var selectedImage: UIImage!
    var filterImages = [UIImage]()
    var filters = [(Any, PSSettingScannerFilter)]()
    var editRowIndex:Int = -1
    
    lazy var brightnessFilter = GPUImageBrightnessFilter()
    var brightness:CGFloat = 0.0
    
    lazy var contrastFilter = GPUImageContrastFilter()
    var contrast:CGFloat = 1.0
    
    public var selectedIndex = IndexPath(row: 0, section: 0)
    
    private lazy var brightnessSlider: FilterSliderView = {
        let _brightnessSlider:FilterSliderView = FilterSliderView.loadXib()!
        _brightnessSlider.filterSlider.minimumValue = -1.0
        _brightnessSlider.filterSlider.maximumValue = 1.0
        _brightnessSlider.filterSlider.setValue(Float(self.brightness), animated: false)
        _brightnessSlider.alpha = 0
        return _brightnessSlider
    }()
    
    private lazy var contrastSlider: FilterSliderView = {
        let _contrastSlider:FilterSliderView = FilterSliderView.loadXib()!
        _contrastSlider.filterSlider.minimumValue = 0.0
        _contrastSlider.filterSlider.maximumValue = 2.0
        _contrastSlider.filterSlider.setValue(Float(self.contrast), animated: false)
        _contrastSlider.alpha = 0
        return _contrastSlider
    }()
    
    private lazy var editBottomView: EditBottomView = {
        let _editBottomView : EditBottomView = EditBottomView.loadXib()!
        _editBottomView.bottomViewType = .secondStep
        return _editBottomView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ScannerEventManager.event(withName: scanner_step3_view, parameters: nil)
    }
    
    override func setupViews() {
        self.needTitleView = true
        super.setupViews()
        
        self.filterCollectionView.delegate = self
        self.filterCollectionView.dataSource = self
        self.filterCollectionView.register(UINib(nibName: ImageFilterCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: ImageFilterCell.getClassName())
        
        self.imageView.image = self.selectedImage
        
        self.bottomView.addSubview(self.editBottomView)
        self.bottomView.backgroundColor = self.editBottomView.backgroundColor
        self.safeBottomView.backgroundColor = self.editBottomView.backgroundColor
        
        self.view.addSubview(self.brightnessSlider)
        self.view.addSubview(self.contrastSlider)
        
        self.editBottomView.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(self.bottomView)
        }
        
        self.brightnessSlider.mas_makeConstraints { (maker) in
            maker?.top.equalTo()(self.bottomView)?.offset()(-90)
            maker?.left.right()?.equalTo()(self.view)
            maker?.height.equalTo()(90)
        }
        
        self.brightnessSlider.filterSliderChangeBlock = {[unowned self](value) in
            self.brightness = CGFloat(value)
            self.brightnessFilter.brightness = self.brightness
            self.imageView.image = GPUFilterHander.getFilterImage(originImage: self.selectedImage, filter: self.brightnessFilter) ?? self.selectedImage
        }
        
        self.contrastSlider.mas_makeConstraints { (maker) in
            maker?.top.equalTo()(self.bottomView)?.offset()(-90)
            maker?.left.right()?.equalTo()(self.view)
            maker?.height.equalTo()(90)
        }
        
        self.contrastSlider.filterSliderChangeBlock = {[unowned self](value) in
            self.contrast = CGFloat(value)
            self.contrastFilter.contrast = self.contrast
            self.imageView.image = GPUFilterHander.getFilterImage(originImage: self.selectedImage, filter: self.contrastFilter) ?? self.selectedImage
        }
        
        self.imageView.mas_makeConstraints { (maker) in
            maker?.centerX.equalTo()(view)
            maker?.top.equalTo()(view)?.offset()(EditScanViewController.topMargin)
            maker?.width.equalTo()(ScreenWidth - 2*EditScanViewController.leftMargin)
            maker?.height.equalTo()(0)
        }
        
        editBottomView.btnClickBlock = {[weak self] (index, selected) in
            switch index {
            case 0:
                self?.leftClick()
            case 1:
                selected ? self?.showFilterSlider(type: .brightness) : self?.hideFilterSlider(type: .brightness)
                ScannerEventManager.event(withName: scanner_step3_brightness_click, parameters: nil)
            case 2:
                selected ? self?.showFilterSlider(type: .contrast) : self?.hideFilterSlider(type: .contrast)
                ScannerEventManager.event(withName: scanner_step3_contrast_click, parameters: nil)
            case 3:
                self?.doneClick()
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.filterCollectionView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateConstraints()
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

    private func leftClick(){
        self.rotationAngle -= 90.0
        if self.rotationAngle == -360.0{
            self.rotationAngle = 0
        }
        self.transformRotationAngle()
        self.hideFilterSlider(type: .brightness)
        self.hideFilterSlider(type: .contrast)
        ScannerEventManager.event(withName: scanner_step3_turn_click, parameters: nil)
    }
    
    private func transformRotationAngle(){
        let result = Measurement(value: self.rotationAngle, unit: UnitAngle.degrees)
        self.imageView.transform = CGAffineTransform(rotationAngle: CGFloat(result.converted(to: .radians).value))
        var scale:CGFloat = 1.0
        if Int(self.rotationAngle/90)%2 != 0 && self.imageView.width > ScreenWidth - 2*EditScanViewController.leftMargin{
            scale = (ScreenWidth - 2*EditScanViewController.leftMargin)/self.imageView.width
        }
        self.imageView.transform = CGAffineTransform(scaleX: scale, y: scale).concatenating(self.imageView.transform)
    }
    
    private func doneClick(){
        let filter = GPUFilterHander.sharedInstance.filters[self.selectedIndex.row].1
        var eventName = scanner_step3_filter_original_ret
        switch filter {
        case .original:
            eventName = scanner_step3_filter_original_ret
        case .scans:
            eventName = scanner_step3_filter_scans_ret
        case .magic:
            eventName = scanner_step3_filter_magic_ret
        case .blackWhite:
            eventName = scanner_step3_filter_bw_ret
        case .grayScale:
            eventName = scanner_step3_filter_grayscale_ret
        case .threshold:
            eventName = scanner_step3_filter_threshold_ret
        }
        ScannerEventManager.event(withName: eventName, parameters: nil)
        ScannerEventManager.event(withName: scanner_step3_done_click, parameters: nil)
        
        
        self.hideFilterSlider(type: .brightness)
        self.hideFilterSlider(type: .contrast)
        guard var image = self.imageView.image else{
            return
        }
        image = image.rotated(by: Measurement<UnitAngle>(value: self.rotationAngle, unit: .degrees)) ?? image
        self.ps_showProgressHUDInWindow()
        DispatchQueue.global().async {
            let imageData = image.compress(byte: 15728640) ?? Data()
            DispatchQueue.main.async {
                self.ps_hideProgressHUDForWindow()
                if let imageScannerController = self.navigationController as? ImageScannerController{
                           let reaml = RLMRealm.default()
                           var fileModel = imageScannerController.selectedDirectory!
                           if self.editRowIndex >= 0{
                               do {
                                   try reaml.transaction {
                                       fileModel.name = imageScannerController.titleStr
                                       fileModel.imageDatas.replaceObject(at: UInt(self.editRowIndex), with: imageData as NSData)
                                   }
                               } catch {}
                           }else{
                               if fileModel.isDir{
                                   fileModel = PSFileModel()
                                   fileModel.isDir = false
                                   fileModel.isRoot = false
                                   fileModel.imageDatas.add(imageData as NSData)
                                   do {
                                       try reaml.transaction {
                                           imageScannerController.selectedDirectory.fileOrDirs.insert(fileModel, at: 0)
                                           fileModel.name = imageScannerController.titleStr
                                           reaml.add(fileModel)
                                       }
                                   } catch {}
                                   
                               }
                               else{
                                   do {
                                       try reaml.transaction {
                                           fileModel.name = imageScannerController.titleStr
                                           fileModel.imageDatas.add(imageData as NSData)
                                       }
                                   } catch{}
                               }
                           }
                           imageScannerController.titleStr = fileModel.name
                       }

                if let imageScannerController = self.navigationController as? ImageScannerController, let vc = imageScannerController.imageScannerDelegate, vc.responds(to: #selector(vc.editScanStepTwoDone(image:scanner:edit:))) {
                           imageScannerController.imageScannerDelegate?.editScanStepTwoDone?(image: image, scanner: imageScannerController, edit: self.editRowIndex >= 0)
                       }
            }
        }
    }
}

extension EditScanStepTwoVC:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageFilterCell.getClassName(), for: indexPath)
        if let filterCell = cell as? ImageFilterCell{
            filterCell.image = self.filterImages[indexPath.row]
            filterCell.title = PSScannerSettingModel.scannerFilterValue(self.filters[indexPath.row].1)
            filterCell.cellSelected = self.selectedIndex.row == indexPath.row
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.selectedIndex.row != indexPath.row else {
            return
        }
        var image = self.image
        if self.filters[indexPath.row].1 != .original{
            self.ps_showProgressHUDInWindow()
            DispatchQueue.global().async {
                image = GPUFilterHander.getFilterImage(originImage: self.image, filter: self.filters[indexPath.row].0)

                DispatchQueue.main.async {
                    self.ps_hideProgressHUDForWindow()
                    self.selectedImage = image
                    self.imageView.image = self.selectedImage
                    
                }
            }
        }else{
            self.selectedImage = image
            self.imageView.image = self.selectedImage
        }
        var reloadIndexs = [self.selectedIndex]
        self.selectedIndex = indexPath
        reloadIndexs.append(self.selectedIndex)
        
        collectionView.performBatchUpdates({
            collectionView.reloadItems(at: reloadIndexs)
        }, completion: nil)
    }
}

extension EditScanStepTwoVC{
    func showFilterSlider(type:FilterSliderType) {
        var view = self.brightnessSlider
        switch type {
        case .contrast:
            view = self.contrastSlider
        default:
            break
        }
        
//        view.mas_updateConstraints { (maker) in
//            maker?.top.equalTo()(self.bottomView)?.offset()(-90)
//        }
        self.view.bringSubviewToFront(view)
        
        UIView.animate(withDuration: 0.25, animations: {
            view.alpha = 1
//            view.superview?.layoutIfNeeded()
        }) { (result) in
            self.hideFilterSlider(type: type == .brightness ? .contrast : .brightness, animation: false)
        }
    }
    
    func hideFilterSlider(type:FilterSliderType, animation:Bool = true) {
        var view = self.brightnessSlider
        switch type {
        case .contrast:
            view = self.contrastSlider
        default:
            break
        }
        
//        view.mas_updateConstraints { (maker) in
//            maker?.top.equalTo()(self.bottomView)?.offset()(0)
//        }
        
        UIView.animate(withDuration: animation ? 0.25 : 0.0) {
            view.alpha = 0
//            view.superview?.layoutIfNeeded()
        }
    }
}
