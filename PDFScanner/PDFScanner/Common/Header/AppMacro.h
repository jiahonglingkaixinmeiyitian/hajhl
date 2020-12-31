//
//  AppMacro.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]

#define WrapInNavigationBar(vc) [[PSBaseNavigationVC alloc] initWithRootViewController:vc]

#define WS(ws) __weak __typeof(&*self)ws = self;

#define kOSVersion [[UIDevice currentDevice].systemVersion floatValue]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width       //屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height     //屏幕高度

#define keyWindowSafeArea [UIApplication sharedApplication].keyWindow.safeAreaInsets

#define AppSafeAreaInset \
({UIEdgeInsets inset = UIEdgeInsetsZero;\
if (@available(iOS 11.0, *)) {\
inset = [UIApplication sharedApplication].keyWindow.safeAreaInsets;\
}\
(inset);})


#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kAppStoreID @"123456"
#define kDomainURL @"https://www.baidu.com"
#define kOCRLanguageCDNDomain @"http://d3po1kzusa3q9k.cloudfront.net/ocr-trained-data/"

#endif /* AppMacro_h */
