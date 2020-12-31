//
//  EditScanOCRResultVC.swift
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/13.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import Loady

class EditScanOCRResultVC: PSBaseVC {

    @IBOutlet weak var scalableImageView: PSScalableImageView!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var textStatusLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var recognizeButton: LoadyButton! {
        didSet {
            recognizeButton.loadingColor = .white
            recognizeButton.backgroundFillColor = .white
            recognizeButton.setAnimation(LoadyAnimationType.android())
        }
    }
    @IBOutlet weak var flagTiledView: PSTiledFlagView!
    
    
    lazy var segmentedControl: UISegmentedControl = {
        let items = ["Image", "Text"]
        let _segmentedControl = UISegmentedControl(items: items)
        _segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme()!], for: .normal)
        _segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        _segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.theme()!], for: [.highlighted, .selected])
        _segmentedControl.selectedSegmentIndex = 0
        if #available(iOS 13.0, *) {
            _segmentedControl.selectedSegmentTintColor = UIColor.theme()
        } else {
            _segmentedControl.tintColor = UIColor.theme()
        }
        _segmentedControl.addTarget(self, action: #selector(clickSegmentedControl(_:)), for: .valueChanged)
        return _segmentedControl
    }()
    lazy var editButton: UIButton = {
        let _button = UIButton(type: .system)
        _button.setTitle("Edit", for: .normal)
        _button.setTitleColor(UIColor.theme(), for: .normal)
        _button.setTitleColor(UIColor.lightGray, for: .disabled)
        _button.addTarget(self, action: #selector(clickEditButton(_:)), for: .touchUpInside)
        return _button
    }()
    lazy var editItem: UIBarButtonItem = {
        let item = UIBarButtonItem(customView: editButton)
        item.isEnabled = false
        return item
    }()
    
    var selectedImage: UIImage!
    var fileModel: PSFileModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = segmentedControl
        self.navigationItem.rightBarButtonItem = editItem
        scalableImageView.scalableImage = selectedImage

        updateFlagImageView()
        
        ScannerEventManager.event(withName: ocr_page_view, parameters: nil)
        self.safeBottomView.backgroundColor = UIColor.theme()

    }
    
    func updateFlagImageView() {
        // set flag
        if PSLanguageModel.selectedLanguageCodes()!.count == 0 {
            flagTiledView.flagCodes = ["eng"] // default: English
        } else {
            flagTiledView.flagCodes = PSLanguageModel.selectedLanguageCodes()
        }
    }
    
    func addDisimssKeyboardButton() {
        
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(dismissKeyboard), for: .touchUpInside)
        button.setTitle("Dismiss keyboard", for: .normal)
        button.setTitleColor(UIColor.theme(), for: .normal)
        button.frame = CGRect(x: ScreenWidth - 40 - 16, y: 0, width: 40, height: 36)
        self.textView.inputAccessoryView = button
        
    }
    
    @objc func dismissKeyboard() {
        textView.resignFirstResponder()
    }

    func _performOCR() {
        // 切换到text tab
        segmentedControl.selectedSegmentIndex = 1
        segmentedControl.sendActions(for: UIControl.Event.valueChanged)
        recognizeButton.startLoading()
        recognizeButton.isUserInteractionEnabled = false
        textStatusLabel.text = "Recognizing..."
        textView.text = nil
        textStatusLabel.isHidden = false
        DispatchQueue.global().async {
            PSTesseract.performOCR(on: self.selectedImage) { [weak self](text) in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.recognizeButton.stopLoading()
                    self.recognizeButton.isUserInteractionEnabled = true
                    if text?.count == 0 {
                        self.textStatusLabel.text = "Nothing recognized."
                    } else {
                        self.textStatusLabel.isHidden = true
                        self.textView.text = text?.replacingOccurrences(of: "\n", with: " ")
                        self.editItem.isEnabled = true
                    }
                }
            }
        }
    }
    
    // MARK: - Action methods
    
    @objc func clickSegmentedControl(_ sender: UISegmentedControl) {
        
        textView.resignFirstResponder()
        if sender.selectedSegmentIndex == 0 {
            scalableImageView.isHidden = false
            textContainer.isHidden = true
            editItem.isEnabled = false
        } else {
            scalableImageView.isHidden = true
            textContainer.isHidden = false
            editItem.isEnabled = self.textView.text.count > 0
        }
    }
    
    @objc func clickEditButton(_ sender: UIButton) {
        //
        addDisimssKeyboardButton()
        self.textView.isEditable = true
        self.textView.becomeFirstResponder()
        moveCursorToFront()
    }
    
    @IBAction func recognizeText(_ sender: Any) {
        
        _performOCR()
    }
    
    @IBAction func selectLanguage(_ sender: UIButton) {
        ScannerEventManager.event(withName: ocr_language_click, parameters: nil)
        let drawer = PSLanguageDrawer()
        drawer.drawerCloseBlock = { [weak self] in
            self?.updateFlagImageView()
        }
        drawer.presentToKeyWindow()
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
            PSShareHelper.share(withText: self.textView.text ?? "", in: self)
        } else if index == 1 {
            // png
            PSShareHelper.share(with: [self.selectedImage.pngData() ?? Data()], fileNames: ["\(self.fileModel.name).png"], in: self)
        } else {
            // pdf
            let pdfData = PSPDFUtil.generatePDFData(withImageDatas: [self.selectedImage.pngData() ?? Data()])
            PSShareHelper.share(with: [pdfData!], fileNames: ["\(self.fileModel.name).pdf"], in: self)
        }
        
    }
    
    private func moveCursorToFront() {
        
        let beginning = textView.beginningOfDocument
        textView.selectedTextRange = textView.textRange(from: beginning, to: beginning)
    }
    
}
