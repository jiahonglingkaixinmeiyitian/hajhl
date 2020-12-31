//
//  UIColor+Style.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/4/23.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "UIColor+Style.h"

@implementation UIColor (Style)

+ (UIColor *)themeColor {
    return UIColorFromRGB(0x2D4056);
}

+ (UIColor *)mainBackgroundColor {
    return UIColorFromRGB(0xEEF1F8);
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)stringToConvert {
    NSScanner *scanner = [NSScanner scannerWithString:[stringToConvert stringByReplacingOccurrencesOfString:@"#" withString:@"0x"] ];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [UIColor colorWithRGBHex:hexNum];
}

#pragma mark - 带透明度
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert andAlpha:(CGFloat)alpha{
    UIColor *color = [UIColor colorWithHexString:stringToConvert];
    return [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:alpha];
}

- (CGFloat)red {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -red");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    return c[0];
}

- (CGFloat)green {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -green");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[1];
}

- (CGFloat)blue {
    NSAssert(self.canProvideRGBComponents, @"Must be an RGB color to use -blue");
    const CGFloat *c = CGColorGetComponents(self.CGColor);
    if (self.colorSpaceModel == kCGColorSpaceModelMonochrome) return c[0];
    return c[2];
}

- (BOOL)canProvideRGBComponents {
    switch (self.colorSpaceModel) {
        case kCGColorSpaceModelRGB:
        case kCGColorSpaceModelMonochrome:
            return YES;
        default:
            return NO;
    }
}

- (CGColorSpaceModel)colorSpaceModel {
    return CGColorSpaceGetModel(CGColorGetColorSpace(self.CGColor));
}

@end
