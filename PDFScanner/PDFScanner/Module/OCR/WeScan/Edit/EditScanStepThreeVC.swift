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
    
    var images = [UIImage]()
    
    private var selectedIndex = IndexPath(row: 0, section: 0) {
        didSet {
            currentSelectedLabel.text = "\(selectedIndex.item + 1)/\(self.images.count)"
        }
    }
    var selectedImage:UIImage!
    private var selectedFile:PSFileModel!
    
    private let imageNumMax = 10
    
    @IBOutlet var scalableImageView: PSScalableImageView!
    @IBOutlet weak var imagesCV: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet var currentSelectedLabel: UILabel!
    
    private var signatureImage:UIImage?
    private var signatureImageSize:CGSize = CGSize(width: 48, height: 48)
    
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
        
        self.imagesCV.dragDelegate = self
        self.imagesCV.dropDelegate = self
        self.imagesCV.dragInteractionEnabled = true
        // Do any additional setup after loading the view.
        ScannerEventManager.event(withName: file_page_view, parameters: nil)
    }
    
    override func setupViews() {
        self.needTitleView = true
        super.setupViews()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navigation_back_icon"), style: .plain, target: self, action: #selector(goBack(sender:)))
        
        if let imageScannerController = navigationController as? ImageScannerController{
            self.selectedFile = imageScannerController.selectedDirectory
        }

        currentSelectedLabel.text = "\(imagesCV.indexPathsForSelectedItems?.first?.item ?? 1)/\(self.images.count)"
        
        self.imagesCV.delegate = self
        self.imagesCV.dataSource = self
        self.imagesCV.register(UINib(nibName: ThumbnailCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: ThumbnailCell.getClassName())
        self.imagesCV.register(UINib(nibName: AddImageCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: AddImageCell.getClassName())
        self.selectedImage = self.images[0]
        self.scalableImageView.scalableImage = self.selectedImage
        
        self.bottomView.addSubview(self.editBottomView)
        self.bottomView.backgroundColor = self.editBottomView.backgroundColor
        self.safeBottomView.backgroundColor = self.editBottomView.backgroundColor
        
        self.editBottomView.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(self.bottomView)
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
                ocrResultVC.fileModel = self?.selectedFile
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
        self.scalableImageView.imageView.addSubview(self.boardView)
        let signatureIV = UIImageView()
        signatureIV.image = self.signatureImage
        self.boardView.contenView = signatureIV
        self.boardView.snp.makeConstraints { (make) in
            make.size.equalTo(self.signatureImageSize)
            make.center.equalToSuperview()
        }

        self.boardView.rectanglePositionClick = { [unowned self](type, boardView) in
            switch type {
            case .leftTop:
                self.cleanSignature()
            case .rightTop:
                ScannerEventManager.event(withName: file_sign_continue_click, parameters: nil)
                self.sureAddSignature()
            default:
                break;
            }
        }
    }
    
    private func sureAddSignature() {
        
        self.boardView.isEdit = false
        
        // 获取签名原始图片
        guard let signatureImage = self.signatureImage else { return }
        
        // 获取真实图片和显示图片的比例
        let scale = self.selectedImage.size.width/self.scalableImageView.imageView.width
        // 照片放大比例
        let zoomScale = self.scalableImageView.scrollView.zoomScale
        
        let signatureRect = CGRect(x: self.boardView.x*scale * zoomScale, y: self.boardView.y*scale * zoomScale, width: self.boardView.width*scale * zoomScale, height: self.boardView.height*scale * zoomScale)
        
        guard let scaleSignatureImage = signatureImage.scaleImage(scaleSize: signatureRect.size.width/signatureImage.size.width) else { return }
        
        self.selectedImage = self.selectedImage.merge(subImage: scaleSignatureImage, subImageOrigin: signatureRect.origin) ?? self.selectedImage
        self.scalableImageView.scalableImage = self.selectedImage
        
        let imageData:Data = self.selectedImage.compress(byte: 15728640) ?? Data()
        self.images[self.selectedIndex.row] = self.selectedImage
        do {
            try RLMRealm.default().transaction {
                
                let pictureModel = self.selectedFile.pictures.object(at: UInt(self.selectedIndex.row))
                pictureModel.imageData = imageData
            }
        } catch {}
        self.imagesCV.reloadItems(at: [self.selectedIndex])
        cleanSignature()
    }
    
    private func cleanSignature() {
        
        self.boardView.removeFromSuperview()
        self.boardView.adjustPosition()
        self.signatureImage = nil
    }

    private func handleShareEvent(_ index: Int) {
        if index == 0 {
            // png
            PSShareHelper.share(with: [self.selectedImage.jpegData(compressionQuality: 1.0)!], fileNames: ["\(self.selectedFile.name).png"], in: self)
            ScannerEventManager.event(withName: file_share_png_click, parameters: nil)
        } else {
            // pdf
            let pdfData = PSPDFUtil.generatePDFData(withImageDatas: [self.selectedImage.pngData()!])
            PSShareHelper.share(with: [pdfData!], fileNames: ["\(self.selectedFile.name).pdf"], in: self)
            ScannerEventManager.event(withName: file_share_pdf_click, parameters: nil)
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
                thumbnailCell.clickDeleteClosure = { [weak self] in
                    self?.deleteImageConfirmAlert(indexPath: indexPath)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let _ = self.signatureImage, self.selectedIndex.row != indexPath.row{
            let deleteSignatureDialog = UIAlertController.init(title: "Don't save signature", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let sureAction =  UIAlertAction(title: "Sure", style: .default, handler: { [unowned self](_) in
                cleanSignature()
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
            nvc.selectedDirectory = self.selectedFile
            nvc.modalPresentationStyle = .fullScreen
            self.present(nvc, animated: true, completion: nil)
            ScannerEventManager.event(withName: file_add_new_click, parameters: nil)
        }else{
            guard self.selectedIndex.row != indexPath.row else {
                return
            }
            self.selectedImage = self.images[indexPath.row]
            self.scalableImageView.scalableImage = self.selectedImage
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
    
    func deleteImageConfirmAlert(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Tips", message: "Are you sure you want to delete the selected file?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let yesAction = UIAlertAction(title: "YES", style: .default) { (action) in
            //
            self.deleteFileAtIndexPath(indexPath)
        }
        alert.addAction(cancelAction)
        alert.addAction(yesAction)
        present(alert, animated: true, completion: nil)
    }
    
    func deleteFileAtIndexPath(_ indexPath: IndexPath) {
        
        images.remove(at: indexPath.item)
        imagesCV.deleteItems(at: [indexPath])
        // delete database file
        do {
            let realm = RLMRealm.default()
            try realm.transaction {
                self.selectedFile.pictures.removeObject(at: UInt(indexPath.item))
                if self.selectedFile.pictures.count == 0 {
                    realm.delete(self.selectedFile)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
        
        if images.count == 0 {
            dismiss(animated: true, completion: nil)
        } else {
            // move to previous one.
            if indexPath.item == 0 {
                selectedIndex = IndexPath(item: 0, section: 0)
            } else {
                selectedIndex = IndexPath(item: indexPath.item - 1, section: 0)
            }
            
            selectedImage = images[selectedIndex.item]
            scalableImageView.scalableImage = selectedImage
            imagesCV.reloadItems(at: [selectedIndex])
            
        }
        
    }
}

extension EditScanStepThreeVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        guard let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        
        let CellWidth = flowLayout.itemSize.width
        let CellCount = self.imageNumMax <= self.images.count ? CGFloat(images.count) : CGFloat(images.count + 1)
        let totalCellWidth = CellWidth * CellCount
        let totalSpacingWidth = flowLayout.minimumLineSpacing * (CellCount - 1)

        let leftInset = (collectionView.frame.size.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2 + flowLayout.sectionInset.left
        let rightInset = leftInset

        return UIEdgeInsets(top: flowLayout.sectionInset.top, left: max(leftInset, flowLayout.sectionInset.left), bottom: flowLayout.sectionInset.bottom, right: max(rightInset, flowLayout.sectionInset.right))
    }

}

extension EditScanStepThreeVC: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        let item = NSItemProvider(object: images[indexPath.item])
        let dragItem = UIDragItem(itemProvider: item)
        return [dragItem]
    }
    
}

extension EditScanStepThreeVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                      canHandle session: UIDropSession) -> Bool {
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
      // 1
      guard let destinationIndexPath = coordinator.destinationIndexPath else {
        return
      }
      
      // 2
      coordinator.items.forEach { dropItem in
        guard let sourceIndexPath = dropItem.sourceIndexPath else {
          return
        }
        
        guard let _ = self.imagesCV.cellForItem(at: destinationIndexPath) as? ThumbnailCell else {
            return
        }

        // 3
        collectionView.performBatchUpdates({
            // image reorder
            let image = self.images[sourceIndexPath.item]
            self.images.remove(at: sourceIndexPath.item)
            self.images.insert(image, at: destinationIndexPath.item)
            self.imagesCV.deleteItems(at: [sourceIndexPath])
            self.imagesCV.insertItems(at: [destinationIndexPath])
            // database data reorder
            do {
                try RLMRealm.default().transaction {
                    //
                    self.selectedFile.pictures.exchangeObject(at: UInt(sourceIndexPath.item), withObjectAt: UInt(destinationIndexPath.item))
                }
            } catch {
                
            }
            
            // update selectedIndex
            if self.selectedIndex == sourceIndexPath {
                
                self.selectedIndex = destinationIndexPath
            } else if self.selectedIndex == destinationIndexPath {
                
                self.selectedIndex = sourceIndexPath
            } else if sourceIndexPath < selectedIndex && selectedIndex < destinationIndexPath {
                
                self.selectedIndex = IndexPath(row: self.selectedIndex.row - 1, section: 0)
            } else if sourceIndexPath > selectedIndex && destinationIndexPath < selectedIndex {
                
                self.selectedIndex = IndexPath(row: self.selectedIndex.row + 1, section: 0)
            }
            
        }, completion: { _ in
          // 4
          coordinator.drop(dropItem.dragItem,
                            toItemAt: destinationIndexPath)
        })
      }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
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
            self.scalableImageView.scalableImage = self.selectedImage
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
        self.scalableImageView.scalableImage = self.selectedImage
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
            UIView.performWithoutAnimation {
                self.imagesCV.performBatchUpdates({
                    self.imagesCV.insertItems(at: [addIndex])
                    self.imagesCV.reloadItems(at: reloadIndexs)
                }, completion: nil)
            }
        }

        scanner.dismiss(animated: true) {
            self.titleStr = self.selectedFile.name
            self.imagesCV.scrollToItem(at: IndexPath.init(row: self.images.count, section: 0), at: .left, animated: true)
        }
    }
}
