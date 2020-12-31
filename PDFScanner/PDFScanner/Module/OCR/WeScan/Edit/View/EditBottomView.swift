//
//  EditBottomView.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class EditBottomView: UIView {
    
    enum BottomViewType {
        case firstStep,secondStep,thirdStep
    }
    
    public var bottomViewType : BottomViewType!{
        didSet{
            if oldValue != bottomViewType {
                setTitles()
            }
        }
    }
    
    @IBOutlet weak var firstBtn: UIView!
    @IBOutlet weak var secondBtn: UIView!
    @IBOutlet weak var thirdBtn: UIView!
    @IBOutlet weak var fourthBtn: UIView!
    @IBOutlet weak var firstLB: UILabel!
    @IBOutlet weak var secondLB: UILabel!
    @IBOutlet weak var thirdLB: UILabel!
    @IBOutlet weak var fourthLB: UILabel!
    @IBOutlet weak var firstIV: UIImageView!
    @IBOutlet weak var secondIV: UIImageView!
    @IBOutlet weak var thirdIV: UIImageView!
    @IBOutlet weak var fourthIV: UIImageView!
    var btns = [UIView]()
    
    var btnClickBlock:((_ index:Int, _ selected:Bool)->(Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btns.append(self.firstBtn)
        btns.append(self.secondBtn)
        btns.append(self.thirdBtn)
        btns.append(self.fourthBtn)
        self.firstBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick(tapGR:))))
        self.secondBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick(tapGR:))))
        self.thirdBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick(tapGR:))))
        self.fourthBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewClick(tapGR:))))
    }
    
    @objc func viewClick(tapGR:UITapGestureRecognizer) {
        if let block = self.btnClickBlock, let view = tapGR.view{
            view.selectedState = !view.selectedState
            btns.forEach { (btn) in
                if btn != view{
                    btn.selectedState = false
                }
            }
            block(view.tag, view.selectedState)
        }
    }
    
    func setTitles(){
        var firstTitle = NSLocalizedString("scan.edit.bottom.step1.all", comment: "")
        var secondTitle = NSLocalizedString("scan.edit.bottom.step1.left", comment: "")
        var thirdTitle = NSLocalizedString("scan.edit.bottom.step1.right", comment: "")
        var fourthTitle = NSLocalizedString("scan.edit.bottom.step1.Continue", comment: "")
        var firstImage = UIImage(named: "icon_all_30_black")
        var secondImage = UIImage(named: "icon_left_30_black")
        var thirdImage = UIImage(named: "icon_right_30_black")
        var fourthImage = UIImage(named: "icon_continue_30_black")
        switch self.bottomViewType {
        case .secondStep:
            firstTitle = NSLocalizedString("scan.edit.bottom.step2.Turn", comment: "")
            secondTitle = NSLocalizedString("scan.edit.bottom.step2.Brightness", comment: "")
            thirdTitle = NSLocalizedString("scan.edit.bottom.step2.Contrast", comment: "")
            fourthTitle = NSLocalizedString("scan.edit.bottom.step2.Done", comment: "")
            
            firstImage = UIImage(named: "icon_turn_30_black")
            secondImage = UIImage(named: "icon_brightness_30_black")
            thirdImage = UIImage(named: "icon_contrast_30_black")
            fourthImage = UIImage(named: "icon_done_30_black")
        case .thirdStep:
            firstTitle = NSLocalizedString("scan.edit.bottom.step3.Share", comment: "")
            secondTitle = NSLocalizedString("scan.edit.bottom.step3.Edit", comment: "")
            thirdTitle = NSLocalizedString("scan.edit.bottom.step3.Sign", comment: "")
            fourthTitle = NSLocalizedString("scan.edit.bottom.step3.OCR", comment: "")
            
            firstImage = UIImage(named: "icon_share_30_black")
            secondImage = UIImage(named: "icon_edit_30_black")
            thirdImage = UIImage(named: "icon_sign_30_black")
            fourthImage = UIImage(named: "icon_ocr_30_black")
        default:
            break
        }
        
        self.firstLB.text = firstTitle
        self.secondLB.text = secondTitle
        self.thirdLB.text = thirdTitle
        self.fourthLB.text = fourthTitle
        
        self.firstIV.image = firstImage
        self.secondIV.image = secondImage
        self.thirdIV.image = thirdImage
        self.fourthIV.image = fourthImage
    }
}

private var selectedStateKey: Void?
extension UIView{
     @objc var selectedState:Bool{
        get {
            if let rs = objc_getAssociatedObject(self, &selectedStateKey) as? Bool {
                return rs
            }
            return false
        }
        set {
            objc_setAssociatedObject(self, &selectedStateKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
