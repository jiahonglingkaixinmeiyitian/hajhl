//
//  UIColor+Extension.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

import UIKit

extension UIColor{
    class func colorWithHexString(colorString: String) -> UIColor {
        
        return self.colorWithHexString(colorString: colorString, alpha: 1)
    }
    
    class func colorWithHexString(colorString: String, alpha: CGFloat) -> UIColor {
        
        if colorString.isEmpty {
            
            return .white
        }
        
        var cString = colorString.uppercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        let length = (cString as NSString).length
        
        if length < 6 || 7 < length || (!cString.hasPrefix("#") && length == 7) {
            
            return .white
        }
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        
        var range = NSRange.init(location: 0, length: 2)
        let rString = (cString as NSString).substring(with: range)
        
        range.location = 2
        let gString = (cString as NSString).substring(with: range)
        
        range.location = 4
        let bString = (cString as NSString).substring(with: range)
        
        var r: CUnsignedInt = 0, g: CUnsignedInt = 0, b: CUnsignedInt = 0
        
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green:  CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}
