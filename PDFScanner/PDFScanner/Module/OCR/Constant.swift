//
//  Constant.swift
//  PDFScanner
//
//  Created by Lcyu on 2020/4/26.
//  Copyright © 2020 cdants. All rights reserved.
//

import Foundation

let KeyWindow                     = UIApplication.shared.keyWindow
let ScreenBounds                  =  UIScreen.main.bounds
let ScreenSize                    =  ScreenBounds.size
let ScreenWidth                   =  CGFloat(ScreenSize.width)
let ScreenHeight                  =  CGFloat(ScreenSize.height)
let NavBarHeight: CGFloat =  UIApplication.shared.statusBarFrame.size.height + 44

/* ---------------------------  Safe  --------------------------- */
let keyWindowSafeArea = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero

/// 图片边距
let imagePadding = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
