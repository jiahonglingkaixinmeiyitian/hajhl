//
//  AppMacro.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#ifndef AppMacro_h
#define AppMacro_h

#define padScale 0.88


#define isHandlePad ({\
BOOL isHandle = NO;\
UIViewController *controller = [PSCurrentViewController currentViewController];\
if (([controller isMemberOfClass:NSClassFromString(@"UPGuidePageController")]||[controller isMemberOfClass:NSClassFromString(@"UPDiscountController")])&&iPadMargin) {\
    isHandle = YES;\
}\
isHandle;\
})

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue&0xFF0000)>>16))/255.0 green:((float)((rgbValue&0xFF00)>>8))/255.0 blue:((float)(rgbValue&0xFF))/255.0 alpha:1.0]

#define WrapInNavigationBar(vc) [[PSBaseNavigationVC alloc] initWithRootViewController:vc]

#define WS(ws) __weak __typeof(&*self)ws = self;

#define kOSVersion [[UIDevice currentDevice].systemVersion floatValue]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width       //屏幕宽度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height     //屏幕高度
#define SAFE_BOTTOM_HEIGHT (LiuHaiPhone ? 34 : 0)

/** -- 判断是否iPhone X -- **/
#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
/** -- iPhoneX / iPhoneXS -- **/
#define  isIphoneX_XS     (SCREEN_WIDTH == 375.f && SCREEN_HEIGHT == 812.f ? YES : NO)
/** -- iPhoneXR / iPhoneXSMax -- **/
#define  isIphoneXR_XSMax    (SCREEN_WIDTH == 414.f && SCREEN_HEIGHT == 896.f ? YES : NO)
/** -- iPhone5 -- **/
#define  isIphone5    (SCREEN_WIDTH == 320.f && SCREEN_HEIGHT == 568.f ? YES : NO)

#define  is_iPhoneP   (SCREEN_WIDTH == 414.f && SCREEN_HEIGHT == 736.f ? YES : NO)

#define ZTStatusBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height)

/** -- 异性全面屏 -- **/
#define  isFullScreen    (isIphoneX_XS || isIphoneXR_XSMax)

#define  iPadMargin (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? YES : NO)
/** -- 安全的NavigationBar高度 -- **/
#define NavigationHeight  (isFullScreen ? 88.f : 64.f)

// 状态栏高度
#define StatusBarHeight    (isFullScreen ? 44.0f : 20.0f)
//tabbar高度
#define TABBAR_HEIGHTHL       (isFullScreen ? 83.0f : 49.0f)

#define BottomBarHeight (isFullScreen ? 34.0f : 0.0f)
#define Nav_TopHeight (StatusBarHeight + NavigationHeight) //整个导航栏高度

#define LiuHaiPhone \
({BOOL isLiuHaiPhone = NO;\
if (@available(iOS 11.0, *)) {\
isLiuHaiPhone = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isLiuHaiPhone);})

#define AppSafeAreaInset \
({UIEdgeInsets inset = UIEdgeInsetsZero;\
if (@available(iOS 11.0, *)) {\
inset = [UIApplication sharedApplication].keyWindow.safeAreaInsets;\
}\
(inset);})


#define AppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define kAppStoreID @"1515420344"
#define kDomainURL @"https://www.baidu.com"
#define kOCRLanguageCDNDomain @"http://d3po1kzusa3q9k.cloudfront.net/ocr-trained-data/"

#if DEBUG
/** -- 测试环境配置 -- **/
#define HttpApiConfig @"https://api.dev.mindu.io/"
#else
/** -- 生产环境配置 -- **/
#define HttpApiConfig @"https://api.pro.scannerocr.com/"//360
#endif

#endif /* AppMacro_h */
