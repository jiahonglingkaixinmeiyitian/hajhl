//
//  EditScanOCRResultVC.swift
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/13.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

class EditScanOCRResultVC: PSBaseVC {

    @IBOutlet var selectedImageView: UIImageView!
    @IBOutlet var textView: UITextView!
    var selectedImage: UIImage!
    var fileModel: PSFileModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "OCR results"
        ScannerEventManager.event(withName: ocr_page_view, parameters: nil)
        self.safeBottomView.backgroundColor = UIColor.theme()
        self.selectedImageView.image = self.selectedImage
        self.selectedImageView.layer.borderColor = UIColor.colorWithHexString(colorString: "#D13D1E").cgColor
        self.selectedImageView.layer.borderWidth = 2
        self.selectedImageView.backgroundColor = .white
        self.textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        _performOCR()
    }
    
    func _performOCR() {
        ps_showProgressHUD(in: self.view)
        DispatchQueue.global(qos: .userInitiated).async {
            PSTesseract.performOCR(on: self.selectedImage) { [weak self](text) in
                DispatchQueue.main.async {
                    self?.ps_hideProgressHUD(for: self?.view)
                    if text?.count == 0 {
                        self?.ps_showHint("Nothing recognized.")
                    } else {
                        self?.textView.text = text
                    }
                }
            }
        }
    }
    
    // MARK: - Action methods
    
    @IBAction func selectLanguage(_ sender: UIButton) {
        ScannerEventManager.event(withName: ocr_language_click, parameters: nil)
        PSLanguageDrawer().presentToKeyWindow()
    }
    
    @IBAction func copyText(_ sender: UIButton) {
        ScannerEventManager.event(withName: ocr_copy_click, parameters: nil)
        UIPasteboard.general.string = self.textView.text
        ps_showHint("Pasted to pasteboard")
    }
    
    @IBAction func clickShareButton(_ sender: UIButton) {
        ScannerEventManager.event(withName: ocr_share_click, parameters: nil)
        let shareDrawer = PSBottomListDrawer(items: [["leftName": "home_share_txt_icon", "rightText": "Share with TXT"],["leftName": "home_share_png_icon", "rightText": "Share with PNG"], ["leftName": "home_share_pdf_icon", "rightText": "Share with PDF"]])
        shareDrawer?.pickListItemBlock = {(index) in
            if index == 0 {
                ScannerEventManager.event(withName: ocr_share_txt_click, parameters: nil)
            } else if index == 1 {
                ScannerEventManager.event(withName: ocr_share_png_click, parameters: nil)
            } else if index == 2 {
                ScannerEventManager.event(withName: ocr_share_pdf_click, parameters: nil)
            }
            self.handleShareEvent(index)
        }
        shareDrawer?.presentToKeyWindow()
    }
    
    private func handleShareEvent(_ index: Int) {

        if index == 0 {
            // txt
            PSShareHelper.share(withText: self.textView.text!, in: self)
        } else if index == 1 {
            // png
            PSShareHelper.share(with: [self.selectedImage.pngData()!], fileNames: ["\(self.fileModel.name!).png"], in: self)
        } else {
            // pdf
            let pdfData = PSPDFUtil.generatePDFData(withImageDatas: [self.selectedImage.pngData()!])
            PSShareHelper.share(with: [pdfData!], fileNames: ["\(self.fileModel.name!).pdf"], in: self)
        }
        
    }
    
}
