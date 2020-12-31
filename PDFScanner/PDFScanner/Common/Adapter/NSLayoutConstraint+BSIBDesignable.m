//
//  NSLayoutConstraint+BSIBDesignable.m
//  PDFScanner
//
//  Created by heartjhl on 2020/6/2.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "NSLayoutConstraint+BSIBDesignable.h"
//#import <objc/runtime.h>


@implementation NSLayoutConstraint (BSIBDesignable)
//- (BOOL)adapterScreen{
//    NSNumber *number = objc_getAssociatedObject(self, _cmd);
//    return number.boolValue;
//}
//
//- (void)setAdapterScreen:(BOOL)adapterScreen{
//    objc_setAssociatedObject(self, @selector(adapterScreen), @(adapterScreen), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    if (adapterScreen) {
//        self.constant = FLoatChange(self.constant);
//    }
//}

- (BOOL)adapterScreen{
    return YES;
}

- (void)setAdapterScreen:(BOOL)adapterScreen{
    if (adapterScreen) {
        self.constant = FLoatChange(self.constant);
    }
}
@end
