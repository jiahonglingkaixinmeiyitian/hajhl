//
//  NSObject+MBProgressHUD.h
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/8.
//  Copyright © 2020 cdants. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MBProgressHUD)

- (void)ps_showHint:(NSString *)hint;

- (void)ps_showProgressHUDInWindow;
- (void)ps_hideProgressHUDForWindow;

- (void)ps_showProgressHUDInView:(UIView *)view;
- (void)ps_hideProgressHUDForView:(UIView *)view;

@end

