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

@end
