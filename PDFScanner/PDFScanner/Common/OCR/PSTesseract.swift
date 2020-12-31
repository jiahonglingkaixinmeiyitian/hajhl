//
//  Test.swift
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/12.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit
import SwiftyTesseract

// setup the data source class
struct DocumentDataSource: LanguageModelDataSource {
    let pathToTrainedData: String
}

class PSTesseract {

    class func performOCR(on image: UIImage, completionHandler: (String?) -> ()) {
        
        let documentsFolder = try! FileManager.default.url(for: .documentDirectory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: false)
        
        let tessData = documentsFolder.appendingPathComponent("tessdata")
        
        let dataSource = DocumentDataSource(pathToTrainedData: tessData.path)
        
        // 从用户选择的语言包读取识别的语言数组
        var languages = [RecognitionLanguage]()
        let languageCodes = PSLanguageModel.selectedLanguageCodes()!
        for code in languageCodes {
            languages.append(.custom(code))
        }
        
        // 如果用户没有选择语言包（用户取消了默认的英文），默认用英文识别
        if languages.count == 0 {
            languages.append(.english)
        }
        
        let swiftyTesseract = SwiftyTesseract(languages: languages, dataSource: dataSource, engineMode: .lstmOnly)
        
        guard case let .success(string) = swiftyTesseract.performOCR(on: image) else {
            completionHandler(nil)
            return
        }
        completionHandler(string)
    }
}
