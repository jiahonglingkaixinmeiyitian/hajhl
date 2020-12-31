//
//  EditScanStepThreeVC.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/13.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import Realm

@objcMembers
class EditScanStepThreeVC: PSBaseVC {
    
    private var rotationAngle:Double = 0.0
    
    var images = [UIImage]()
    
    private var selectedIndex = IndexPath(row: 0, section: 0)
    var selectedImage:UIImage!
    private var selectedDirectory:PSFileModel!
    
    private let imageNumMax = 10
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imagesCV: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var imagesFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var cvLeftConstraint: NSLayoutConstraint!
    @IBOutlet weak var cvRightConstraint: NSLayoutConstraint!
    
    private var signatureImage:UIImage?
    private var signatureImageSize:CGSize = CGSize(width: 80, height: 80)
    
    private lazy var editBottomView: EditBottomView = {
        let _editBottomView : EditBottomView = EditBottomView.loadXib()!
        _editBottomView.bottomViewType = .thirdStep
        return _editBottomView
    }()
    
    private lazy var boardView:BoardView = {
        let _boardView : BoardView = BoardView.loadXib()!
        _boardView.isEdit = true
        _boardView.minScale = 0.8
        return _boardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ScannerEventManager.event(withName: file_page_view, parameters: nil)
    }
    
    override func setupViews() {
        self.needTitleView = true
        super.setupViews()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_back_icon"), style: .plain, target: self, action: #selector(goBack(sender:)))
        
        if let imageScannerController = navigationController as? ImageScannerController{
            self.selectedDirectory = imageScannerController.selectedDirectory
        }
        
        self.imagesCV.delegate = self
        self.imagesCV.dataSource = self
        self.imagesCV.register(UINib(nibName: ThumbnailCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: ThumbnailCell.getClassName())
        self.imagesCV.register(UINib(nibName: AddImageCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: AddImageCell.getClassName())
        self.selectedImage = self.images[0]
        self.imageView.image = self.selectedImage
        
        self.bottomView.addSubview(self.editBottomView)
        self.bottomView.backgroundColor = self.editBottomView.backgroundColor
        self.safeBottomView.backgroundColor = self.editBottomView.backgroundColor
        
        self.editBottomView.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(self.bottomView)
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
                // Share
                ScannerEventManager.event(withName: file_share_click, parameters: nil)
                let shareDrawer = PSBottomListDrawer(items: [["leftName": "home_share_png_icon", "rightText": "Share with PNG"], ["leftName": "home_share_pdf_icon", "rightText": "Share with PDF"]])
                shareDrawer?.pickListItemBlock = {(index) in
                    self?.handleShareEvent(index)
                }
                shareDrawer?.presentToKeyWindow()
            case 1:
                self?.edit()
            case 2:
                self?.signature()
            case 3:
                // OCR
                let ocrResultVC = EditScanOCRResultVC()
                ocrResultVC.fileModel = self?.selectedDirectory
                ocrResultVC.selectedImage = self?.selectedImage
                self?.navigationController?.pushViewController(ocrResultVC, animated: true)
                ScannerEventManager.event(withName: file_ocr_click, parameters: nil)
            default:
                break
            }
        }
    }
    
    private func edit(){
        let editVC = EditScanViewController(image: self.selectedImage, quad: nil, rotateImage: false)
        editVC.editRowIndex = self.selectedIndex.row
        self.navigationController?.pushViewController(editVC, animated: false)
        ScannerEventManager.event(withName: file_edit_click, parameters: nil)
    }
    
    private func signature(){
        let signatureView:PSSignatureView = PSSignatureView.loadXib()!
        let drawer = PSBottomDrawer()
        signatureView.continueClickBlock = { [unowned self, drawer](image) in
            self.signatureImage = image
            self.addSignatureImage()
            drawer.dismiss()
        }
        self.view.addSubview(drawer)
        drawer.setContentView(signatureView)
        signatureView.mas_makeConstraints { (maker) in
            maker?.height.equalTo()(578)
        }
        drawer.presentToKeyWindow()
        ScannerEventManager.event(withName: file_sign_click, parameters: nil)
    }
    
    private func addSignatureImage(){
        self.boardView.isEdit = true
        self.imageView.addSubview(self.boardView)
        let signatureIV = UIImageView()
        signatureIV.image = self.signatureImage
        self.boardView.contenView = signatureIV
        self.boardView.mas_makeConstraints { (maker) in
            maker?.size.equalTo()(self.signatureImageSize)
            maker?.center.equalTo()(self.boardView.superview)
        }
        self.boardView.rectanglePositionClick = { [unowned self](type, boardView) in
            switch type {
            case .leftTop:
                self.cancelAddSignature()
            case .rightTop:
                ScannerEventManager.event(withName: file_sign_continue_click, parameters: nil)
                self.sureAddSignature()
            default:
                break;
            }
        }
    }
    
    private func sureAddSignature(){
        self.boardView.isEdit = false
        
        if let signatureImage = self.signatureImage{
            let scale = self.selectedImage.size.width/self.imageView.width
            let signatureRect = CGRect(x: self.boardView.x*scale, y: self.boardView.y*scale, width: self.boardView.width*scale, height: self.boardView.height*scale)
            if let scaleSignatureImage = signatureImage.scaleImage(scaleSize: signatureRect.size.width/signatureImage.size.width){
                self.selectedImage = self.selectedImage.merge(subImage: scaleSignatureImage, subImageOrigin: signatureRect.origin) ?? self.selectedImage
                self.imageView.image = self.selectedImage
                
                let imageData:Data = self.selectedImage.compress(byte: 15728640) ?? Data()
                self.images[self.selectedIndex.row] = self.selectedImage
                do {
                    try RLMRealm.default().transaction {
                        self.selectedDirectory.imageDatas.replaceObject(at: UInt(self.selectedIndex.row), with: imageData as NSData)
                    }
                } catch {}
                self.imagesCV.reloadItems(at: [self.selectedIndex])
                self.boardView.removeFromSuperview()
                self.signatureImage = nil
            }
        }
    }
    
    private func cancelAddSignature(){
        self.boardView.removeFromSuperview()
        self.signatureImage = nil
    }
    
    private func handleShareEvent(_ index: Int) {
        if index == 0 {
            // png
            PSShareHelper.share(with: [self.selectedImage.jpegData(compressionQuality: 1.0)!], fileNames: ["\(self.selectedDirectory.name!).png"], in: self)
            ScannerEventManager.event(withName: file_share_png_click, parameters: nil)
        } else {
            // pdf
            let pdfData = PSPDFUtil.generatePDFData(withImageDatas: [self.selectedImage.pngData()!])
            PSShareHelper.share(with: [pdfData!], fileNames: ["\(self.selectedDirectory.name!).pdf"], in: self)
            ScannerEventManager.event(withName: file_share_pdf_click, parameters: nil)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self.updateConstraints()
    }
    
    private func updateConstraints() {
        let imageSize = self.selectedImage.size
        
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
        
        let imagesCVMinWidth = (CGFloat(self.imageNumMax <= self.images.count ? self.images.count : self.images.count + 1)) * self.imagesFlowLayout.itemSize.width + CGFloat(self.images.count) * self.imagesFlowLayout.minimumLineSpacing + self.imagesFlowLayout.sectionInset.left + self.imagesFlowLayout.sectionInset.right
        if self.view.width > imagesCVMinWidth{
            self.cvLeftConstraint.constant = (self.view.width - imagesCVMinWidth)/2
            self.cvRightConstraint.constant = (self.view.width - imagesCVMinWidth)/2
        }else{
            self.cvLeftConstraint.constant = 0
            self.cvRightConstraint.constant = 0
        }
    }
    
    @objc private func goBack(sender:Any){
        self.dismiss(animated: true, completion: nil)
    }
}

extension EditScanStepThreeVC : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageNumMax <= self.images.count ? self.images.count : self.images.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCell(withReuseIdentifier: ThumbnailCell.getClassName(), for: indexPath)
        if indexPath.row >= self.images.count && self.images.count < self.imageNumMax{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddImageCell.getClassName(), for: indexPath)
        }else{
            if let thumbnailCell = cell as? ThumbnailCell{
                thumbnailCell.image = self.images[indexPath.row]
                thumbnailCell.selectedState = self.selectedIndex.row == indexPath.row
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = self.signatureImage, self.selectedIndex.row != indexPath.row{
            let deleteSignatureDialog = UIAlertController.init(title: "Don't save signature", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let sureAction =  UIAlertAction(title: "Sure", style: .default, handler: { [unowned self](_) in
                self.signatureImage = nil
                self.boardView.removeFromSuperview()
                self.changeSelectedIndex(indexPath: indexPath)
            })
            deleteSignatureDialog.addAction(cancelAction)
            deleteSignatureDialog.addAction(sureAction)
            self.present(deleteSignatureDialog, animated: true, completion: nil)
            return
        }
        self.changeSelectedIndex(indexPath: indexPath)
    }
    
    private func changeSelectedIndex(indexPath:IndexPath){
        if indexPath.row == self.images.count && self.images.count < self.imageNumMax{
            let nvc = ImageScannerController(delegate: self)
            nvc.selectedDirectory = self.selectedDirectory
            nvc.modalPresentationStyle = .fullScreen
            self.present(nvc, animated: true, completion: nil)
            ScannerEventManager.event(withName: file_add_new_click, parameters: nil)
        }else{
            guard self.selectedIndex.row != indexPath.row else {
                return
            }
            self.selectedImage = self.images[indexPath.row]
            self.imageView.image = self.selectedImage
            self.updateConstraints()
            var reloadIndexs = [self.selectedIndex]
            self.selectedIndex = indexPath
            reloadIndexs.append(self.selectedIndex)
            
            UIView.performWithoutAnimation {
                self.imagesCV.performBatchUpdates({
                    self.imagesCV.reloadItems(at: reloadIndexs)
                }, completion: nil)
            }
        }
    }
}

extension EditScanStepThreeVC:ImageScannerControllerDelegate{
    func imageScannerControllerDidCancel(_ scanner: ImageScannerController) {
        scanner.dismiss(animated: true, completion: nil)
        self.titleStr = scanner.selectedDirectory.name
    }
    
    func imageScannerController(_ scanner: ImageScannerController, didFailWithError error: Error) {
        
    }
    
    func editScanStepTwoDone(image: UIImage, scanner: ImageScannerController, edit: Bool) {
        if edit {
            self.selectedImage = image
            self.images[self.selectedIndex.row] = self.selectedImage
            self.imageView.image = self.selectedImage
            UIView.performWithoutAnimation {
                self.imagesCV.performBatchUpdates({
                    self.imagesCV.reloadItems(at: [self.selectedIndex])
                }, completion: nil)
            }
            if let vcs = self.navigationController?.viewControllers{
                for vc in vcs {
                    if vc is EditScanStepThreeVC{
                        self.navigationController?.popToViewController(vc, animated: true)
                    }
                }
            }
            return
        }
        
        let addIndex = IndexPath.init(row: self.images.count, section: 0)
        self.images.append(image)
        self.selectedImage = image
        self.imageView.image = self.selectedImage
        var reloadIndexs = [self.selectedIndex]
        self.selectedIndex = addIndex
        reloadIndexs.append(self.selectedIndex)
        if self.images.count >= self.imageNumMax{
            UIView.performWithoutAnimation {
                self.imagesCV.performBatchUpdates({
                    self.imagesCV.reloadItems(at: reloadIndexs)
                }, completion: nil)
            }
        }else{
            self.updateConstraints()
            UIView.performWithoutAnimation {
                self.imagesCV.performBatchUpdates({
                    self.imagesCV.insertItems(at: [addIndex])
                    self.imagesCV.reloadItems(at: reloadIndexs)
                }, completion: nil)
            }
        }

        scanner.dismiss(animated: true) {
            self.titleStr = self.selectedDirectory.name
            self.imagesCV.scrollToItem(at: IndexPath.init(row: self.images.count, section: 0), at: .left, animated: true)
        }
    }
}
