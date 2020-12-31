//
//  NSObject+Extension.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

import Foundation

extension NSObject{
    class func getClassName()->String{
        let name = NSStringFromClass(classForCoder()) as String
        if(name.contains(".")){
            return name.components(separatedBy: ".")[1];
        }else{
            return name;
        }
    }
    
    class func getClassName(anyClass :AnyClass)->String{
        let name = NSStringFromClass(anyClass) as String
        if(name.contains(".")){
            return name.components(separatedBy: ".")[1];
        }else{
            return name;
        }
    }
}
