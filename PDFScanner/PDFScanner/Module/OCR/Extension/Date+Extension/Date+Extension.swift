//
//  Date+Extension.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/15.
//  Copyright © 2020 cdants. All rights reserved.
//

import Foundation

extension Date{
    static func format(form timeInterval:TimeInterval, formatStr:String) ->String{
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = formatStr //"yyyy-MM-dd HH:mm:ss"
        return dateformatter.string(from: date)
    }
    
    static func getCurrentEnglishDateStr()->String{
        return Date.format(form: Date.timeIntervalBetween1970AndReferenceDate, formatStr: "MM-DD-yyyy")
    }
}
