//
//  UIFont+Style.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/11.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "UIFont+Style.h"

@implementation UIFont (Style)

+ (instancetype)appRegularFontSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"GlacialIndifference-Regular" size:fontSize];
}

+ (instancetype)appBoldFontSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"GlacialIndifference-Bold" size:fontSize];
}

+ (instancetype)appItalicFontSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"GlacialIndifference-Italic" size:fontSize];
}

+(UIFont *)pfhkrFont:(CGFloat)fontSize{
//    return [UIFont fontWithName:@"PingFangHK-Regular" size: fontSize];
    return [UIFont fontWithName:@"PingFangSC-Regular" size: fontSize];
}

+(UIFont *)pfhkmFont:(CGFloat)fontSize{
//   return [UIFont fontWithName:@"PingFangHK-Medium" size: fontSize];
    return [UIFont fontWithName:@"PingFangSC-Medium" size: fontSize];
}

+(UIFont *)pfhksFont:(CGFloat)fontSize{
//    return [UIFont fontWithName:@"PingFangHK-Semibold" size: fontSize];
    return [UIFont fontWithName:@"PingFangSC-Semibold" size: fontSize];
}




+(UIFont *)pfscrFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Regular" size: fontSize];
}

+(UIFont *)pfscmFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Medium" size: fontSize];
}

+(UIFont *)pfscsFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangSC-Semibold" size: fontSize];
}

+(UIFont *)pftcmFont:(CGFloat)fontSize{
   return [UIFont fontWithName:@"PingFangTC-Medium" size: fontSize];
}

+(UIFont *)pftcrFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"PingFangTC-Regular" size: fontSize];
}


+(UIFont *)mymnbFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"MyanmarMN-Bold" size: fontSize];
}

+(UIFont *)sfpmFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"SFProText-Medium" size: fontSize];
}

+(UIFont *)sfprFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"SFProText-Regular" size: fontSize];
}

+(UIFont *)gibFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"GlacialIndifference-Bold" size: fontSize];
}

+(UIFont *)giiFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"GlacialIndifference-Italic" size: fontSize];
}

+(UIFont *)girFont:(CGFloat)fontSize{
    return [UIFont fontWithName:@"GlacialIndifference-Regular" size: fontSize];
}

@end
