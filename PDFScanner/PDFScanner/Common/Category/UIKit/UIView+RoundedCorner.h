//
//  UIView+RoundedCorner.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/7.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundedCorner)

- (void)ps_roundCorners:(UIRectCorner)corners radius:(CGFloat)radius;

- (void)ps_applyGradientColors:(NSArray *)colors;

@end

