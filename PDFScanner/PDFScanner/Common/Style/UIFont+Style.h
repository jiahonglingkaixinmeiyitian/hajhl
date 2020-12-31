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

@end

