//
//  ScannerTopCenterView.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class ScannerTopCenterView: UIView {
    enum ScannerTopCenterViewBtnType:Int {
        case auto = 1, manual = 2
    }

    @IBOutlet weak var autoBtn: UIButton!
    @IBOutlet weak var manualBtn: UIButton!
    
    private var selectedBtn: UIButton?
    
    var btnSelectedBlock:((_ type:ScannerTopCenterViewBtnType)->Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.autoBtn.setTitle(NSLocalizedString("scan.camera.top.button.auto" , comment: ""), for: .normal)
        self.setBtnStyle(btn: self.autoBtn)

        self.manualBtn.setTitle(NSLocalizedString("scan.camera.top.button.manual" , comment: ""), for: .normal)
        self.setBtnStyle(btn: self.manualBtn)
        self.setSelectedBtn(type: .auto)
    }
    
    func setBtnStyle(btn:UIButton){
        btn.setTitleColor(UIColor.colorWithHexString(colorString: "#CCCCCC"), for: .normal)
        btn.setTitleColor(UIColor.colorWithHexString(colorString: "#FFFFFF"), for: .selected)
        btn.setTitleColor(UIColor.colorWithHexString(colorString: "#FFFFFF"), for: UIControl.State.init(rawValue: UIControl.State.selected.rawValue | UIControl.State.highlighted.rawValue))
    }
    
    func setSelectedBtn(type:ScannerTopCenterViewBtnType?){
        if let type = type, let btn = self.viewWithTag(type.rawValue) as? UIButton{
            guard btn != self.selectedBtn else {
                return
            }
            if let oldBtn = self.selectedBtn{
                oldBtn.isSelected = false
                oldBtn.titleLabel?.font = UIFont.appRegularFontSize(18)
            }
            self.selectedBtn = btn
            self.selectedBtn?.isSelected = true
            self.selectedBtn?.titleLabel?.font = UIFont.appBoldFontSize(18)
            self.btnSelectedBlock?(type)
        }
    }
    @IBAction func btnClick(_ sender: UIButton) {
        self.setSelectedBtn(type: ScannerTopCenterViewBtnType.init(rawValue: sender.tag))
    }
}
