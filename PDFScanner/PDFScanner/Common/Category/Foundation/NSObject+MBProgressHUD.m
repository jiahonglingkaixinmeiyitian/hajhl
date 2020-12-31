//
//  NSObject+MBProgressHUD.m
//  PDFScanner
//
//  Created by Lucy Benson on 2020/5/8.
//  Copyright © 2020 cdants. All rights reserved.
//

#import "NSObject+MBProgressHUD.h"

@implementation NSObject (MBProgressHUD)

- (void)ps_showHint:(NSString *)hint {
    
    UIView *myView = [[UIApplication sharedApplication] keyWindow];
    
    MBProgressHUD *previousHUD = [MBProgressHUD HUDForView:myView];
    MBProgressHUD *hud;
    
    if (previousHUD) {
        hud = previousHUD;
    } else {
        hud = [MBProgressHUD showHUDAddedTo:myView animated:YES];
    }
    
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    [hud.bezelView setColor:[UIColor colorWithWhite:0 alpha:0.6]];
    hud.bezelView.layer.cornerRadius = 3.f;

    hud.detailsLabel.text = hint;
    hud.detailsLabel.font = [UIFont systemFontOfSize:12.f];
    hud.detailsLabel.textColor = [UIColor whiteColor];
    hud.detailsLabel.textAlignment = NSTextAlignmentLeft;
    hud.offset = CGPointMake(hud.offset.x, hud.offset.y);
    hud.margin = 10.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
}

- (void)ps_showProgressHUDInWindow {
    
    [self ps_showProgressHUDInView:[UIApplication sharedApplication].keyWindow];
}

- (void)ps_hideProgressHUDForWindow {
    
    [self ps_hideProgressHUDForView:[UIApplication sharedApplication].keyWindow];
}

- (void)ps_showProgressHUDInView:(UIView *)view {
    
    MBProgressHUD *previousHUD = [MBProgressHUD HUDForView:view];
    if (previousHUD) {
        [previousHUD hideAnimated:NO];
    }
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

- (void)ps_hideProgressHUDForView:(UIView *)view {
    
    [MBProgressHUD hideHUDForView:view animated:YES];
}

@end
