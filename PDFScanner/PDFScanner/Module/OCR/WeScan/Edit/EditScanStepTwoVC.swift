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
    
    @IBOutlet var scalableImageView: PSScalableImageView!
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
    
    public var selectedIndex = 0
    
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
        
        configDefaultSelectedIndex()
        
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
            self.scalableImageView.scalableImage = GPUFilterHander.getFilterImage(originImage: self.selectedImage, filter: self.brightnessFilter) ?? self.selectedImage
            
        }
        
        self.contrastSlider.mas_makeConstraints { (maker) in
            maker?.top.equalTo()(self.bottomView)?.offset()(-90)
            maker?.left.right()?.equalTo()(self.view)
            maker?.height.equalTo()(90)
        }
        
        self.contrastSlider.filterSliderChangeBlock = {[unowned self](value) in
            self.contrast = CGFloat(value)
            self.contrastFilter.contrast = self.contrast
            self.scalableImageView.scalableImage = GPUFilterHander.getFilterImage(originImage: self.selectedImage, filter: self.contrastFilter) ?? self.selectedImage
            
        }

        editBottomView.btnClickBlock = {[weak self] (index, selected) in
            switch index {
            case 0:
                self?.clickClockwise()
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
    
    func configDefaultSelectedIndex() {
        
        if let imageScannerController = self.navigationController as? ImageScannerController {
            if imageScannerController.selectedDirectory.isDir == true {
                // is dir. new file.
                if let settingModel = PSScannerSettingModel.allObjects().firstObject() as? PSScannerSettingModel{
                    selectedIndex = settingModel.scannerFilter.rawValue
                }
            } else {
                // is old file
                let pictures = imageScannerController.selectedDirectory.pictures
                if editRowIndex >= 0 && editRowIndex < pictures.count {
                    selectedIndex = pictures.object(at: UInt(editRowIndex)).appliedFilter.intValue
                }
            }
        }
        
        // apply filter image
//        transferToGPUFilter
        if let GPUFilter = GPUFilterHander.sharedInstance.transferToGPUFilter(scannerFilter: PSSettingScannerFilter(rawValue: selectedIndex)!) {
            if let filterImage = GPUFilterHander.getFilterImage(originImage: image, filter: GPUFilter) {
                selectedImage = filterImage
            } else {
                selectedImage = image
            }
        } else {
            selectedImage = image
        }
        
        // display filtered image
        self.scalableImageView.scalableImage = self.selectedImage
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.filterCollectionView.scrollToItem(at: IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: true)
    }

    private func clickClockwise() {

        self.scalableImageView.rotate(direction: .clockwise)
        self.hideFilterSlider(type: .brightness)
        self.hideFilterSlider(type: .contrast)
        ScannerEventManager.event(withName: scanner_step3_turn_click, parameters: nil)
    }
    
    private func doneClick(){
        let filter = GPUFilterHander.sharedInstance.filters[selectedIndex].1
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
        guard var image = self.scalableImageView.scalableImage else{
            return
        }
        image = image.rotated(by: Measurement<UnitAngle>(value: self.scalableImageView.rotationAngle, unit: .degrees)) ?? image
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
                                       fileModel.name = imageScannerController.titleStr ?? ""
                                    
                                       let pictureModel = PSPictureModel()
                                       pictureModel.imageData = imageData
                                       pictureModel.appliedFilter = self.selectedIndex as NSNumber
                                    
                                       fileModel.pictures.replaceObject(at: UInt(self.editRowIndex), with: pictureModel)
                                    
                                   }
                               } catch {}
                           }else{
                               if fileModel.isDir{
                                   fileModel = PSFileModel()
                                   fileModel.isDir = false
                                   fileModel.isRoot = false
                                
                                   let pictureModel = PSPictureModel()
                                   pictureModel.imageData = imageData
                                   pictureModel.appliedFilter = self.selectedIndex as NSNumber
                                
                                   fileModel.pictures.add(pictureModel)
                                   do {
                                       try reaml.transaction {
                                           imageScannerController.selectedDirectory.fileOrDirs.insert(fileModel, at: 0)
                                           fileModel.name = imageScannerController.titleStr ?? ""
                                           reaml.add(fileModel)
                                       }
                                   } catch {}
                                   
                               }
                               else{
                                   do {
                                       try reaml.transaction {
                                           fileModel.name = imageScannerController.titleStr ?? ""
                                        
                                           let pictureModel = PSPictureModel()
                                           pictureModel.imageData = imageData
                                           pictureModel.appliedFilter = self.selectedIndex as NSNumber
                                        
                                           fileModel.pictures.add(pictureModel)
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
            filterCell.image = self.filterImages[indexPath.item]
            filterCell.title = PSScannerSettingModel.scannerFilterValue(self.filters[indexPath.item].1)
            filterCell.cellSelected = self.selectedIndex == indexPath.item
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard self.selectedIndex != indexPath.item else {
            return
        }
        var image = self.image
        if self.filters[indexPath.item].1 != .original{
            self.ps_showProgressHUDInWindow()
            DispatchQueue.global().async {
                image = GPUFilterHander.getFilterImage(originImage: self.image, filter: self.filters[indexPath.item].0)

                DispatchQueue.main.async {
                    self.ps_hideProgressHUDForWindow()
                    self.selectedImage = image
                    self.scalableImageView.scalableImage = self.selectedImage
                    
                }
            }
        }else{
            self.selectedImage = image
            self.scalableImageView.scalableImage = self.selectedImage
        }
        var reloadIndexs = [IndexPath(item: selectedIndex, section: 0)]
        self.selectedIndex = indexPath.item
        reloadIndexs.append(IndexPath(item: selectedIndex, section: 0))
        
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
        
        self.view.bringSubviewToFront(view)
        
        UIView.animate(withDuration: 0.25, animations: {
            view.alpha = 1
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
        
        UIView.animate(withDuration: animation ? 0.25 : 0.0) {
            view.alpha = 0
        }
    }
}
