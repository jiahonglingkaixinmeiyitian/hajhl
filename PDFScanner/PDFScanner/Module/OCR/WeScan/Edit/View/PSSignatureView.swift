//
//  PSSignatureView.swift
//  PDFScanner
//
//  Created by lcyu on 2020/5/14.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import Masonry
import Realm

class PSSignatureView: UIView {
    
    @IBOutlet weak var clearLB: UILabel!
    @IBOutlet weak var continueLB: UILabel!
    @IBOutlet weak var signatureView: UIView!
    @IBOutlet weak var signatureCV: UICollectionView!
    private var signatureImages:[UIImage] = []
    private var currentSignatureImage:UIImage?
    
    private var selectedIndex = IndexPath(row: 0, section: 0)
    
    var continueClickBlock:((_ image:UIImage)->Void)?
    
    
    private lazy var signatureVC: SignatureDrawingViewController = {
        let _signatureVC : SignatureDrawingViewController = SignatureDrawingViewController()
        return _signatureVC
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clearLB.isUserInteractionEnabled = true
        self.clearLB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clearClick)))
        self.continueLB.isUserInteractionEnabled = true
        self.continueLB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(continueClick)))
        self.signatureView.addSubview(self.signatureVC.view)
        
        self.signatureVC.view.mas_makeConstraints { (maker) in
            maker?.edges.equalTo()(self.signatureView)
        }
        self.signatureVC.touchesEndBlock = { [unowned self](vc) in
            if let image = vc.fullSignatureImage{
                self.currentSignatureImage = image
                self.signatureCV.reloadItems(at: [IndexPath(row: 0, section: 0)])
            }
        }
        
        self.signatureCV.delegate = self
        self.signatureCV.dataSource = self
        self.signatureCV.register(UINib(nibName: PSSignatureCell.getClassName(), bundle: nil), forCellWithReuseIdentifier: PSSignatureCell.getClassName())
        if let models = PSSignatureModel.allModels() as? [PSSignatureModel], models.count > 0{
            models.forEach { (model) in
                self.signatureImages.append(UIImage(data: model.imageData)!)
            }
        }
        self.signatureCV.reloadData()
    }
    
    @objc func clearClick(){
        self.currentSignatureImage = nil
        if self.selectedIndex.row == 0{
            self.signatureVC.reset()
        }
            UIView.performWithoutAnimation {
                self.signatureCV.performBatchUpdates({
                    self.signatureCV.reloadItems(at: [IndexPath(row: 0, section: 0)])
                }, completion: nil)
            }
        
    }
    
    @objc func continueClick(){
        
        if self.selectedIndex.row == 0{
            if let image = self.currentSignatureImage{
                let model = PSSignatureModel()
                model.imageData = image.pngData()
                do {
                    try RLMRealm.default().transaction {
                        RLMRealm.default().add(model)
                    }
                }catch{}
                self.continueClickBlock?(image)
            }
        }else{
            self.continueClickBlock?(self.signatureImages[self.selectedIndex.row - 1])
        }
    }
}

extension PSSignatureView:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.signatureImages.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =
            self.signatureCV.dequeueReusableCell(withReuseIdentifier: PSSignatureCell.getClassName(), for: indexPath)
        if let cell = cell as? PSSignatureCell{
            cell.imageView.image = indexPath.row == 0 ? self.currentSignatureImage : self.signatureImages[indexPath.row - 1];
            cell.cellSelected = self.selectedIndex.row == indexPath.row
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.selectedIndex.row != indexPath.row{
            guard self.selectedIndex.row != indexPath.row else {
                return
            }
            self.signatureVC.reset()
            self.signatureVC.presetImage = indexPath.row == 0 ? self.currentSignatureImage : self.signatureImages[indexPath.row - 1]
            self.signatureVC.view.isUserInteractionEnabled = indexPath.row == 0
            self.signatureVC.viewWillAppear(false)
            var reloadIndexs = [self.selectedIndex]
            self.selectedIndex = indexPath
            reloadIndexs.append(self.selectedIndex)
            
            UIView.performWithoutAnimation {
                self.signatureCV.performBatchUpdates({
                    self.signatureCV.reloadItems(at: reloadIndexs)
                }, completion: nil)
            }
            
            if self.selectedIndex.row > 0 {
                // 如果选中的是历史签名,帮用户自动点击continue按钮
                self.continueClickBlock?(self.signatureImages[self.selectedIndex.row - 1])
            }
        }
    }
}
