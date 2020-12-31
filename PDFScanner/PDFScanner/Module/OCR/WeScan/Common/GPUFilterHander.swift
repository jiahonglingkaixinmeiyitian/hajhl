//
//  GPUFilterHander.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

import GPUImage

@objc class GPUFilterHander: NSObject {
    @objc static let sharedInstance: GPUFilterHander = {
        let instance = GPUFilterHander()
        return instance
    }()
    
    @objc lazy var scansFilter:GPUImageHighlightShadowFilter = {
        let _scansFilter = GPUImageHighlightShadowFilter()
        _scansFilter.shadows = 1.0
        return _scansFilter
    }()
    
    @objc lazy var magicFilter:GPUImageSharpenFilter = {
        let _magicFilter = GPUImageSharpenFilter()
        _magicFilter.sharpness = 3.5
        return _magicFilter
    }()
    
    @objc lazy var bwFilter:GPUImageAdaptiveThresholdFilter = {
        let _bwFilter = GPUImageAdaptiveThresholdFilter()
        _bwFilter.blurRadiusInPixels = 1.0
        return _bwFilter
    }()
    
    @objc lazy var grayscaleFilter:GPUImageGrayscaleFilter = GPUImageGrayscaleFilter()
    
    @objc lazy var thresholdFilter:GPUImageLuminanceThresholdFilter = GPUImageLuminanceThresholdFilter()
    
    lazy var filters:[(Any, PSSettingScannerFilter)] = [("Origin", .original),(scansFilter, .scans), (magicFilter, .magic), (bwFilter, .blackWhite), (grayscaleFilter, .grayScale), (thresholdFilter, .threshold)]
    
    @objc class func getFilterImage(originImage:UIImage, filter:Any) -> UIImage? {
        if let f = filter as? GPUImageFilter{
            return originImage.filter(imageFilter: f)
        }else if let f = filter as? GPUImageFilterGroup{
            return originImage.filterGroup(imageFilterGroup: f)
        }
        return originImage
    }
    
    func getFilterImages(image:UIImage, compressByte:Int = 102400) -> [UIImage] {
        var filterImages = [UIImage]()
        let compressImage:UIImage = image.compress(byte: compressByte)
        //        self.configFilters()
        self.filters.forEach { (filter, type) in
            if type == .original{
                filterImages.append(image)
            }
            else if let image = GPUFilterHander.getFilterImage(originImage: compressImage, filter: filter){
                filterImages.append(image)
            }else{
                filterImages.append(compressImage)
            }
        }
        return filterImages
    }
    
    public func getSelectedFilter()->(Int, (Any, PSSettingScannerFilter))?{
        if let settingModel = PSScannerSettingModel.allObjects().firstObject() as? PSScannerSettingModel{
            if let index = self.filters.firstIndex(where: { (_, filter) -> Bool in
                return filter == settingModel.scannerFilter
            }){
                return (index, self.filters[index])
            }
        }
        return nil
    }
    
    private func configFilters(){
        if let settingModel = PSScannerSettingModel.allObjects().firstObject() as? PSScannerSettingModel{
            if let index = self.filters.firstIndex(where: { (_, filter) -> Bool in
                return filter == settingModel.scannerFilter
            }){
                self.filters.insert(self.filters.remove(at: index), at: 0)
            }
            
        }
    }
}
