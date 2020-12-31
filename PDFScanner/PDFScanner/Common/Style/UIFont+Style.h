//
//  UIFont+Style.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Style)

+ (instancetype)appRegularFontSize:(CGFloat)fontSize;
+ (instancetype)appBoldFontSize:(CGFloat)fontSize;
+ (instancetype)appItalicFontSize:(CGFloat)fontSize;

///苹方-港 常规体
//+(UIFont *)pfhkrFont:(CGFloat)fontSize;
///苹方-港 中黑体
//+(UIFont *)pfhkmFont:(CGFloat)fontSize;
///苹方-港 中粗体
//+(UIFont *)pfhksFont:(CGFloat)fontSize;
/***************************************************/
///苹方-简 常规体
+(UIFont *)pfscrFont:(CGFloat)fontSize;
///苹方-简 中黑体
+(UIFont *)pfscmFont:(CGFloat)fontSize;
///苹方-简 中粗体
+(UIFont *)pfscsFont:(CGFloat)fontSize;
///苹方-繁 中黑体
+(UIFont *)pftcmFont:(CGFloat)fontSize;
///苹方-繁 常规体
+(UIFont *)pftcrFont:(CGFloat)fontSize;
///Myanmar MN Bold
+(UIFont *)mymnbFont:(CGFloat)fontSize;

+(UIFont *)sfpmFont:(CGFloat)fontSize;

+(UIFont *)sfprFont:(CGFloat)fontSize;

+(UIFont *)gibFont:(CGFloat)fontSize;

+(UIFont *)giiFont:(CGFloat)fontSize;

+(UIFont *)girFont:(CGFloat)fontSize;

@end

