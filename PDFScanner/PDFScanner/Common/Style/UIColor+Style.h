//
//  UIColor+Style.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

#define COLOR(c) [UIColor colorWithHexString:c]
#define FONT(f) [UIFont systemFontOfSize:f]

@interface UIColor (Style)

+ (UIColor *)themeColor;
+ (UIColor *)mainBackgroundColor;


+ (UIColor *)colorWithRGBHex:(UInt32)hex;

/**
 HEX
 
 @param stringToConvert 0x000000
 @return UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;


/**
  传入#AABBCC

 @param stringToConvert 0xFFFFFF
 @param alpha 透明度
 @return Color
 */
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha;

@end

