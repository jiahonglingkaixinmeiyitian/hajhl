//
//  Constant.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/4/26.
//  Copyright © 2020 cdants. All rights reserved.
//

import Foundation

func isIPHONEX() -> Bool {
    if #available(iOS 11, *), let window = KeyWindow, window.safeAreaInsets.bottom > 0{
        return true
    }
    return false
}

let KeyWindow                     = UIApplication.shared.keyWindow
let ScreenBounds                  =  UIScreen.main.bounds
let ScreenSize                    =  ScreenBounds.size
let ScreenWidth                   =  CGFloat(ScreenSize.width)
let ScreenHeight                  =  CGFloat(ScreenSize.height)
/* ---------------------------  Safe  --------------------------- */
let StatusBarHeight       =  CGFloat(isIPHONEX() ? 44.0 : 20.0)
let NavBarHeight             =  CGFloat(isIPHONEX() ? 88.0 : 64.0)
let TabBarHeight         = CGFloat(isIPHONEX() ? 83.0 : 49.0)
let SafeAreaInsetsBottom = CGFloat(isIPHONEX() ? 34.0 : 0)


